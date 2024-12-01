import torch
from torch import nn
from torch.nn.utils import prune
from models import QuantConv2d

def ws_prune_vgg16(model, prune_percentage:float): 
    first_conv = True
    for l in model.features: 
        if isinstance(l, nn.Conv2d) and not first_conv: 
            k1, k2 = l.weight.size(2), l.weight.size(3)
            ws_conv_prune(l, round(prune_percentage*k1*k2), ln=1)
        elif isinstance(l, nn.Conv2d) and first_conv: 
            first_conv = False # Skip first conv layer

def os_prune_vgg16(model, prune_percentage:float): 
    first_conv = True
    for l in model.features: 
        if isinstance(l, nn.Conv2d) and not first_conv: 
            ic = l.weight.size(1)
            os_conv_prune(l, round(prune_percentage*ic), ln=1)
        elif isinstance(l, nn.Conv2d) and first_conv: 
            first_conv = False # Skip first conv layer

def print_sparsity(model): 
    for i, l in enumerate(model.features): 
        if isinstance(l, nn.Conv2d) and hasattr(l, 'weight_mask'): 
            print(f'layer {i} sparsity: {(l.weight_mask==0).sum()/l.weight_mask.numel():.3f}')

def ws_conv_prune(conv_layer:nn.Conv2d, num_prune_sticks:int, ln:int=1): 
    num_sticks = conv_layer.weight.size(2)*conv_layer.weight.size(3)
    print(f'Pruning {num_prune_sticks} kij-sticks out of {num_sticks} kij-sticks per output channel ({num_prune_sticks/num_sticks:.1%} pruned)')

    num_oc, num_ic, k1, k2 = conv_layer.weight.shape
    
    mask = torch.empty(conv_layer.weight.shape, dtype=torch.bool, device=conv_layer.weight.device)
    with torch.no_grad(): 
        for oc in range(num_oc): 
            num_already_pruned = (conv_layer.weight_mask[oc,0,:,:]==0).sum().item() if hasattr(conv_layer, 'weight_mask') else 0
            weight_block = conv_layer.weight[oc,:,:,:] # (ic, k, k)
            norms = torch.norm(weight_block, p=ln, dim=(0), keepdim=True)
            threshold = norms.view((-1)).topk(k=num_prune_sticks+num_already_pruned, largest=False).values[-1]
            mask[oc,:,:,:] = (norms > threshold).expand(num_ic, k1, k2)
        prune.custom_from_mask(conv_layer, 'weight', mask)

def os_conv_prune(conv_layer:nn.Conv2d, num_prune_slices:int, ln:int=1): 
    num_slices = conv_layer.weight.size(1)
    print(f'Pruning {num_prune_slices} ic-slices out of {num_slices} ic-slices per output channel ({num_prune_slices/num_slices:.1%} pruned)')
    
    num_oc, num_ic, k1, k2 = conv_layer.weight.shape

    mask = torch.empty(conv_layer.weight.shape, dtype=torch.bool, device=conv_layer.weight.device)
    with torch.no_grad(): 
        for oc in range(num_oc): 
            num_already_pruned = (conv_layer.weight_mask[oc,:,0,0]==0).sum().item() if hasattr(conv_layer, 'weight_mask') else 0
            weight_block = conv_layer.weight[oc,:,:,:] # (ic, k, k)
            norms = torch.norm(weight_block, p=ln, dim=(1,2), keepdim=True)
            threshold = norms.view((-1)).topk(k=num_prune_slices+num_already_pruned, largest=False).values[-1]
            mask[oc,:,:,:] = (norms > threshold).expand(num_ic, k1, k2)
        prune.custom_from_mask(conv_layer, 'weight', mask)

def quantize_pruned(model): 
    for i, l in enumerate(model.features): 
        if isinstance(l, nn.Conv2d) and hasattr(l, 'weight_mask'): 
            ql = QuantConv2d(l.in_channels, l.out_channels, l.kernel_size[0], l.stride, 
                            l.padding, l.dilation, l.groups, l.bias, bits=4).cuda()
            ql.weight.data = l.weight.data.detach().clone() # copy original weights
            prune.custom_from_mask(ql, 'weight', l.weight_mask) # Add pruning parameters here with the correct weight_mask
            model.features[i] = ql # replace layer

if __name__=='__main__': 
    dd = nn.Conv2d(4,2,3)
    print(dd.weight)
    os_conv_prune(dd,1,1)
    print(dd.weight)
    os_conv_prune(dd,1,1)
    print(dd.weight)
