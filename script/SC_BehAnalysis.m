dataDir = '/matlab_users/Alan/sleepInterference/SleepConsolidation/data';
%subs = {'22Mar12_113'};
%subs =  {'17Mar12_100'  '17Mar12_101' '17Mar12_102'  '19Mar12_103'  '19Mar12_104'  '21Mar12_106' '21Mar12_107' '21Mar12_108' '21Mar12_109' '21Mar12_110' '22Mar12_111' '22Mar12_112' '22Mar12_113'};
subs =  {'21Mar12_106' '21Mar12_107' '21Mar12_108' '21Mar12_109' '21Mar12_110' '22Mar12_111' '22Mar12_112' '22Mar12_113'};

    
    
   
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

    %%
    
    idx.interference = ismember(A, allAC.A);
    idx.BCued = ismember(A, A_BSleepCued);
    idx.CCued = ismember(A, A_CSleepCued);
    idx.junkStim = ismember(A, repeatedImgs);
    idx.noCue = ~(idx.BCued + idx.CCued);   
    
    idx.BRetrievalPracticeCor = ismember(A, A_BRPCor);
    idx.CRetrievalPracticeCor = ismember(A, A_CRPCor);
        
    N(s,1) = sum(idx.interference .* idx.CCued .* ~idx.junkStim);
    N(s,2) = sum(idx.interference .* idx.BCued .* ~idx.junkStim);
    N(s,3) = sum(idx.interference .* idx.noCue .* ~idx.junkStim);
    N(s,4) = sum(~idx.interference .* idx.BCued .* ~idx.junkStim);
    N(s,5) = sum(~idx.interference .* idx.noCue .* ~idx.junkStim);
    
    res(s,1) = sum(idx.correct .* idx.interference .* idx.CCued .* ~idx.junkStim) / N(s,1);
    res(s,2) = sum(idx.correct .* idx.interference .* idx.BCued .* ~idx.junkStim) / N(s,2);
    res(s,3) = sum(idx.correct .* idx.interference .* idx.noCue .* ~idx.junkStim) / N(s,3);
    res(s,4) = sum(idx.correct .* ~idx.interference .* idx.BCued .* ~idx.junkStim) / N(s,4);
    res(s,5) = sum(idx.correct .* ~idx.interference .* idx.noCue .* ~idx.junkStim) / N(s,5);
    
    res2(s,1) = mean(allAB.corReh);
    res2(s,2) = mean(allAC.corReh);
    
    res3(s,1) = sum(idx.BRetrievalPracticeCor .* idx.interference .* idx.CCued .* ~idx.junkStim) / N(s,1);
    res3(s,2) = sum(idx.BRetrievalPracticeCor .* idx.interference .* idx.BCued .* ~idx.junkStim) / N(s,2);
    res3(s,3) = sum(idx.BRetrievalPracticeCor.* idx.interference .* idx.noCue .* ~idx.junkStim) / N(s,3);
    res3(s,4) = sum(idx.BRetrievalPracticeCor .* ~idx.interference .* idx.BCued .* ~idx.junkStim) / N(s,4);
    res3(s,5) = sum(idx.BRetrievalPracticeCor .* ~idx.interference .* idx.noCue .* ~idx.junkStim) / N(s,5);
    
    res4(s,1) = sum(idx.CRetrievalPracticeCor .* idx.interference .* idx.CCued .* ~idx.junkStim) / N(s,1);
    res4(s,2) = sum(idx.CRetrievalPracticeCor .* idx.interference .* idx.BCued .* ~idx.junkStim) / N(s,2);
    res4(s,3) = sum(idx.CRetrievalPracticeCor.* idx.interference .* idx.noCue .* ~idx.junkStim) / N(s,3);
    
    res5(s,1) = sum(idx.correct .* idx.BRetrievalPracticeCor .* ~idx.junkStim) / sum(idx.BRetrievalPracticeCor .* ~idx.junkStim);
    res5(s,2) = sum(idx.correct .* ~idx.BRetrievalPracticeCor .* ~idx.junkStim) /  sum(~idx.BRetrievalPracticeCor .* ~idx.junkStim);  
    
    res6(s,1) = sum(idx.correct .* idx.CRetrievalPracticeCor .* ~idx.junkStim) / sum(idx.CRetrievalPracticeCor .* ~idx.junkStim);
    res6(s,2) = sum(idx.correct .* ~idx.CRetrievalPracticeCor .* ~idx.junkStim) /  sum(~idx.CRetrievalPracticeCor .* ~idx.junkStim);  
 
    
    corVec_h{s} = idx.correct(~idx.junkStim);
    intVec_h{s} = idx.interference(~idx.junkStim);
    BCueVec_h{s} = idx.BCued(~idx.junkStim);
    CCueVec_h{s} = idx.CCued(~idx.junkStim);
    subVec_h{s} = s*ones(size(corVec_h{s}));
    corRehB_h{s} = idx.BRetrievalPracticeCor(~idx.junkStim);
    corRehC_h{s} = idx.CRetrievalPracticeCor(~idx.junkStim);
    
end

%bar plot of the data.
barweb(mean(res), std(res)/sqrt(size(res,1)))

%bar plot of the data.
% barweb(mean(res2), std(res2)/sqrt(size(res2,1)))
% 
% %bar plot of the data.
% barweb(mean(res3), std(res3)/sqrt(size(res3,1)))
% 
% %bar plot of the data.
% barweb(mean(res4), std(res4)/sqrt(size(res4,1)))
% 
% %bar plot of the data.
% barweb(mean(res5), std(res5)/sqrt(size(res5,1)))
% 
% %bar plot of the data.
barweb(mean(res6), std(res6)/sqrt(size(res6,1)))

[~, p1] = ttest(res(:,1), res(:,2));
[~, p2] = ttest(res(:,3), res(:,4));
[~, p3] = ttest(res(:,4), res(:,5));
[~, p4] = ttest(res(:,1), res(:,3));


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

cell2csv('/matlab_users/Alan/sleepInterference/SleepConsolidation/analyses/groupBehDat.csv', toPrint, ',', 2000);

