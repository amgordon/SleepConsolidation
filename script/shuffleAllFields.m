function [S] = shuffleAllFields(S)

fn = fieldnames(S);

idxShuffle = shuffle(1:length(S.(fn{1})));

fieldLength = length(idxShuffle);

for f = 1:length(fn)
    
    if length(S.(fn{f}))~=fieldLength
        error('not all fields are the same length.');
    end
    
    S.(fn{f}) = S.(fn{f})(idxShuffle);
end
