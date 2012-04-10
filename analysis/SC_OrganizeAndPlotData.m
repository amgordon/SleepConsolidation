%dataDir = '/matlab_users/Alan/sleepInterference/SleepConsolidation/data';
dataDir =  '/Users/alangordon/Studies/sleepInterference/SleepConsolidation/data';

%subs = {'22Mar12_113'};
%subs =  {'17Mar12_100'  '17Mar12_101' '17Mar12_102'  '19Mar12_103'  '19Mar12_104'  '21Mar12_106' '21Mar12_107' '21Mar12_108' '21Mar12_109' '21Mar12_110' '22Mar12_111' '22Mar12_112' '22Mar12_113'};
subs =  {'21Mar12_106' '21Mar12_107' '21Mar12_108' '21Mar12_109' '21Mar12_110' '22Mar12_111' '22Mar12_112' '22Mar12_113'  '31Mar12_200'    '31Mar12_201'    '31Mar12_203'    '31Mar12_204'    '31Mar12_205' '31Mar12_206'    '04Apr12_1'    '04Apr12_4'    '04Apr12_5'    '04Apr12_6'    '04Apr12_7'};
%subs = {'04Apr12_1'    '04Apr12_4'    '04Apr12_5'    '04Apr12_6'    '04Apr12_7'};
    
    
   
nConds = 5;
nSubs = length(subs);
res = nan(length(subs), nConds);

for s = 1:length(subs)
    thisSub = subs{s};
    
    cd (fullfile(dataDir, thisSub));
    
    % match the data files
    dStudy = dir('*_Study_*');
    dSleep = dir('*Sleep*');
    dTest = dir('*test*');
    
    %% Test Phase
    R = load(dTest(1).name);
    
    theData = R.theData;
    
    idxNotEmpty = ~cellfun(@isempty, theData.typedResp);
    
    resps = upper(theData.typedResp)';
    answers = theData.correctAssociate;
    A = theData.A;

    idx.correct = strcmp(resps,answers);
    
    %% Sleep Phras
    T = load(dSleep.name);
    
    sleepCues = T.SleepData.cue;
    
    %% Study Phase
    for d=1:length(dStudy)
        Q{d} = load(dStudy(d).name);
        
        AB.A{d} = Q{d}.learnDataAB.A;
        AC.A{d} = Q{d}.learnDataAC.A;
        
        AB.cue{d} = Q{d}.learnDataAB.cue;
        AC.cue{d} = Q{d}.learnDataAC.cue;
        
        AB.corReh{d} = strcmpi(Q{d}.rehDataAB.typedResp',Q{d}.rehDataAB.B);
        AC.corReh{d} = strcmpi(Q{d}.rehDataAC.typedResp',Q{d}.rehDataAC.C);
    end
    
    allAB.A = vertcat(AB.A{:});
    allAC.A = vertcat(AC.A{:});
    
    allAB.cue = vertcat(AB.cue{:});
    allAC.cue = vertcat(AC.cue{:});
    
    allAB.corReh = vertcat(AB.corReh{:});
    allAC.corReh = vertcat(AC.corReh{:});
    
    A_BRPCor = allAB.A(allAB.corReh);
    A_CRPCor = allAC.A(allAC.corReh);

    
    
    %% 
    %create an index of stims mistakenly repeated during the AB phase
    for i=1:length(allAB.A)
       thisImg = allAB.A{i};
       tmpArray = allAB.A;
       tmpArray(i) = [];
       idx.repeat(i) = ismember(thisImg, tmpArray);
    end
    
    % stims that were mistakenly presented twice during the AB phase
    repeatedImgs = unique(allAB.A(idx.repeat));
    
    [Imgs_BSleepCued, ~, ixB] = intersect(sleepCues, allAB.cue);
    [Imgs_CSleepCued, ~, ixC] = intersect(sleepCues, allAC.cue);
    
    A_BSleepCued = allAB.A(ixB);
    A_CSleepCued = allAC.A(ixC);

    %% indices of groups of interest    
    idx.interference = ismember(A, allAC.A);
    idx.BCued = ismember(A, A_BSleepCued);
    idx.CCued = ismember(A, A_CSleepCued);
    idx.junkStim = ismember(A, repeatedImgs);
    idx.noCue = ~(idx.BCued + idx.CCued);   
    
    idx.BRetrievalPracticeCor = ismember(A, A_BRPCor);
    idx.CRetrievalPracticeCor = ismember(A, A_CRPCor);
    
    %% sample size in each group.  
    N(s,3) = sum(idx.interference .* idx.CCued .* ~idx.junkStim);
    N(s,2) = sum(idx.interference .* idx.BCued .* ~idx.junkStim);
    N(s,1) = sum(idx.interference .* idx.noCue .* ~idx.junkStim);
    N(s,5) = sum(~idx.interference .* idx.BCued .* ~idx.junkStim);
    N(s,4) = sum(~idx.interference .* idx.noCue .* ~idx.junkStim);
    
    %% results structures
    
    %was test accuracy different across interference and cueing categories?
    res.TestAccByMemoryCategory(s,3) = sum(idx.correct .* idx.interference .* idx.CCued .* ~idx.junkStim) / N(s,3);
    res.TestAccByMemoryCategory(s,2) = sum(idx.correct .* idx.interference .* idx.BCued .* ~idx.junkStim) / N(s,2);
    res.TestAccByMemoryCategory(s,1) = sum(idx.correct .* idx.interference .* idx.noCue .* ~idx.junkStim) / N(s,1);
    res.TestAccByMemoryCategory(s,5) = sum(idx.correct .* ~idx.interference .* idx.BCued .* ~idx.junkStim) / N(s,5);
    res.TestAccByMemoryCategory(s,4) = sum(idx.correct .* ~idx.interference .* idx.noCue .* ~idx.junkStim) / N(s,4);
    
    %was rehearsal accuracy across AB and AC rehearsal trials?
    res.Rehearsal(s,1) = mean(allAB.corReh);
    res.Rehearsal(s,2) = mean(allAC.corReh);
    
    %was "B" rehearsal performance constant across memory categories?
    res.BRehActByMemoryCategory(s,3) = sum(idx.BRetrievalPracticeCor .* idx.interference .* idx.CCued .* ~idx.junkStim) / N(s,3);
    res.BRehActByMemoryCategory(s,2) = sum(idx.BRetrievalPracticeCor .* idx.interference .* idx.BCued .* ~idx.junkStim) / N(s,2);
    res.BRehActByMemoryCategory(s,1) = sum(idx.BRetrievalPracticeCor.* idx.interference .* idx.noCue .* ~idx.junkStim) / N(s,1);
    res.BRehActByMemoryCategory(s,5) = sum(idx.BRetrievalPracticeCor .* ~idx.interference .* idx.BCued .* ~idx.junkStim) / N(s,5);
    res.BRehActByMemoryCategory(s,4) = sum(idx.BRetrievalPracticeCor .* ~idx.interference .* idx.noCue .* ~idx.junkStim) / N(s,4);
    
    %was "C" rehearsal performance constant across memory categories?
    res.CRehActByMemoryCategory(s,3) = sum(idx.CRetrievalPracticeCor .* idx.interference .* idx.CCued .* ~idx.junkStim) / N(s,3);
    res.CRehActByMemoryCategory(s,2) = sum(idx.CRetrievalPracticeCor .* idx.interference .* idx.BCued .* ~idx.junkStim) / N(s,2);
    res.CRehActByMemoryCategory(s,1) = sum(idx.CRetrievalPracticeCor.* idx.interference .* idx.noCue .* ~idx.junkStim) / N(s,1);
    
    %did "B" rehearsal accuracy affect subsequent test accuracy?
    res.BTestAccByBRehAct(s,1) = sum(idx.correct .* idx.BRetrievalPracticeCor .* ~idx.junkStim) / sum(idx.BRetrievalPracticeCor .* ~idx.junkStim);
    res.BTestAccByBRehAct(s,2) = sum(idx.correct .* ~idx.BRetrievalPracticeCor .* ~idx.junkStim) /  sum(~idx.BRetrievalPracticeCor .* ~idx.junkStim);  
    
    %did "C" rehearsal accuracy affect subsequent test accuracy?
    res.CTestAccByBRehAct(s,1) = sum(idx.correct .* idx.CRetrievalPracticeCor .* ~idx.junkStim) / sum(idx.CRetrievalPracticeCor .* ~idx.junkStim);
    res.CTestAccByBRehAct(s,2) = sum(idx.correct .* ~idx.CRetrievalPracticeCor .* ~idx.junkStim) /  sum(~idx.CRetrievalPracticeCor .* ~idx.junkStim);  
 
    
    %helper variables to store raw data for future export
    corVec_h{s} = idx.correct(~idx.junkStim);
    intVec_h{s} = idx.interference(~idx.junkStim);
    BCueVec_h{s} = idx.BCued(~idx.junkStim);
    CCueVec_h{s} = idx.CCued(~idx.junkStim);
    subVec_h{s} = s*ones(size(corVec_h{s}));
    corRehB_h{s} = idx.BRetrievalPracticeCor(~idx.junkStim);
    corRehC_h{s} = idx.CRetrievalPracticeCor(~idx.junkStim);
    
end

%% group plotting 

fn = fieldnames(res);

for f=1:length(fn)
    figure;
    thisRes = res.(fn{f});
    barweb(mean(thisRes), std(thisRes)/sqrt(size(thisRes,1)));
end


%% output the data to a csv, so it can be imported into R
allCorVec = vertcat(corVec_h{:});
allIntVec = vertcat(intVec_h{:});
allBCueVec = vertcat(BCueVec_h{:});
allCCueVec = vertcat(CCueVec_h{:});
allSubVec = vertcat(subVec_h{:});
allCorRehBVec = vertcat(corRehB_h{:});
allCorRehCVec = vertcat(corRehC_h{:});

toPrint(:,1) = ['cor'; num2cell(allCorVec)];
toPrint(:,2) = ['Int'; num2cell(allIntVec)];
toPrint(:,3) = ['BCue'; num2cell(allBCueVec)];
toPrint(:,4) = ['CCue'; num2cell(allCCueVec)];
toPrint(:,5) = ['subs'; num2cell(allSubVec)];
toPrint(:,6) = ['corRehB'; num2cell(allCorRehBVec)];
toPrint(:,7) = ['corRehC'; num2cell(allCorRehCVec)];

cell2csv('/Users/alangordon/Studies/sleepInterference/SleepConsolidation/analysis/groupBehDat.csv', toPrint, ',', 2000);

