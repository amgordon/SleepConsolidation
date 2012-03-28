function [S] = subIdxAllFields(S,idx)

fn = fieldnames(S);

fieldLength = length(S.(fn{1}));

for f = 1:length(fn)
    
    if length(S.(fn{f}))~=fieldLength
        error('not all fields are the same length.');
    end
    
    S.(fn{f}) = S.(fn{f})(idx);
end

