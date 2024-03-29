function SC_calculatePayment(dataMat)

valPerCorrectTrial = 1;
nSubsetTrials = 5;

d = load(dataMat);

if isfield(d, 'TestData')
    theData = d.TestData.block;
else
    theData = d.theData;
end

idxCleanResp = find(~cellfun(@isempty, theData.typedResp));
nTrials = length(idxCleanResp);

if nTrials<nSubsetTrials
   warning('not enough trials, using %g of them', nTrials);
   nSubsetTrials = nTrials;
end


idxShuffle_h = shuffle(idxCleanResp);
idxShuffle = idxShuffle_h(1:nSubsetTrials);
 

resps = upper(theData.typedResp(idxShuffle))';

if isfield(theData, 'correctAssociate')
    answers = theData.correctAssociate(idxShuffle);
elseif isfield(theData, 'B')
    answers = theData.B(idxShuffle);
elseif isfield(theData, 'C')
    answers = theData.C(idxShuffle);
else
    error('unrecognized behavioral file')
end


detectCorrect = sum(strcmp(resps,answers));

[['responses'; ' '; resps], ['answers'; ' '; answers]]

cor = input(sprintf('I detected %g correct. How many are actually correct? ', detectCorrect));

sprintf('payment is $%g .', valPerCorrectTrial*cor)