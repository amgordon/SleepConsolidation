
function k = SCgetKeyboardNumber
% Gets laptop internal keyboard for Ben's laptop, INERTIA

d=PsychHID('Devices');

usages = {d.usageName};
IDs = [d.productID];

k = 0;

usageIdx = find(strcmp(usages, 'Keyboard'));

if isempty(usageIdx)
    error('No keyboard recognized.')
elseif sum(abs(diff(usageIdx)))>0;
    error('Multiple keyboards with different IDs recognized.')
else
    k = usageIdx(1);
end
    
