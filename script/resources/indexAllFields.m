function [ Sout ] = indexAllFields(S, idx)
    fn = fieldnames(S);
    
    for f=1:length(fn)
        curField = S.(fn{f});
        Sout.(fn{f}) = curField(idx);        
    end



end

