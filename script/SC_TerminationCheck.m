function [] = SC_TerminationCheck(subInput, terminationCode )


if ~isempty(strfind(subInput, terminationCode))
    sca;
    ListenChar(1);
    error('Script terminated with %s key.', terminationCode);
end




