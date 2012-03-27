function [  ] = SC_MakeLists(thePath)

% Written by Alan M. Gordon, Stanford Memory Lab
% March 14, 2012

%use prepend in data file names

%condition labels:
% 1: AB-AC, C played at sleep
% 2: AB-AC, B played at sleep
% 3: AB-AC, no sound at sleep
% 4: AB, no sound at sleep
% 5: AB, B played at sleep

%number of classes for each stimulus type
nClasses.sounds = 8;
nClasses.imgs = 5;
nClasses.words = 8;

%total number of lists to generate.  best if it's a common multiple of the
%nClasses
nLists = 40;

%number of runs for each task.
nSubLists = 10;

nPracticeStims = 5;

%load sound stims
cd(thePath.stim)
allSounds = load('soundList');
allSounds = allSounds.soundList';

%load word stims
allWords = load('wordList');
allWords = allWords.wordList';

%load image stims.  
cd(thePath.SVLO);
dImgs = dir('*.jpg');
allImgs = {dImgs.name};

%the number of trials per condition
nTrials = 20; %change to 25 eventually, when we have the full # of sounds.

classVec.sounds = 1:nClasses.sounds;
classVec.imgs = 1:nClasses.imgs;
classVec.words = 1:nClasses.words;

%total number of sound, image, and word stims
nStims.sounds = nTrials * nClasses.sounds;
nStims.imgs = nTrials * nClasses.imgs;
nStims.words = nTrials * nClasses.words;

%create set of condition assignments for sounds
for k=1:nStims.sounds
    condsAssignment_h{k} = 1 + mod(classVec.sounds+k-2, nClasses.sounds);
end
condsAssignment = vertcat(condsAssignment_h{:});

%randomly Shuffle sounds, images, and words.  
ShuffledSounds = Shuffle(allSounds);
ShuffledImgs = Shuffle(allImgs);
ShuffledWords = Shuffle(allWords);

%make practice lists
cd(thePath.list);

thisList.cond = zeros(nPracticeStims,1);
thisList.cue = ShuffledSounds(1:nPracticeStims);
thisList.A = ShuffledImgs(1:nPracticeStims);
thisList.B = ShuffledWords(1:nPracticeStims);

save practiceStudyList thisList;

thisList = shuffleAllFields(thisList);
save practiceRehList thisList;

%toss the practice stims
ShuffledSounds(1:nPracticeStims) = [];
ShuffledImgs(1:nPracticeStims) = [];
ShuffledWords(1:nPracticeStims) = [];

for i = 1:nLists
        
        iSound = 1+mod(i-1,nClasses.sounds);
        
        thisSubListSoundsIdx = (1:nStims.sounds );
        thisSubListImgsIdx = (1:nStims.imgs );
        thisSubListWordsIdx = (1:nStims.words );
        
        thisSubList.sounds = ShuffledSounds(thisSubListSoundsIdx)';
        thisSubList.imgs_h = ShuffledImgs(thisSubListImgsIdx)';
        thisSubList.words = ShuffledWords(thisSubListWordsIdx)' ;
        
        thisSubList.conds = condsAssignment(thisSubListSoundsIdx,iSound);

        % repeat some of the A stimuli
        idxFirstImgs = ismember(thisSubList.conds, [1:5]);
        idxRepeatedImgs = ismember(thisSubList.conds, [6:8]);
        thisSubList.imgs = cell(size(thisSubList.conds));
        
        thisSubList.imgs(idxFirstImgs)=thisSubList.imgs_h;
        condsFirstImages = thisSubList.conds(idxFirstImgs);
        thisSubList.imgs(idxRepeatedImgs) = thisSubList.imgs_h(ismember(condsFirstImages,[1:3]));
          
        % make sure no matched B and C words begin with the same letter.
        % keep substituting out 'offending' C words that have the same
        % letter as their B counterpart with other words randomly selected
        % from the list, until there are no more offending words.  
        BIntWords = thisSubList.words(ismember(thisSubList.conds, [1:3]));
        
        while true
            potentialCWords = thisSubList.words(ismember(thisSubList.conds, [6:8]));
            initialC = cellfun(@(x) x(1), BIntWords, 'UniformOutput',false);
            initialB = cellfun(@(x) x(1), potentialCWords, 'UniformOutput',false);
            idxSameFirstLetter = strcmp(initialC,initialB);
            if sum(idxSameFirstLetter)==0
                break
            end
            offendingWords = potentialCWords(idxSameFirstLetter);
            
            
            switchWordsPool = setdiff(potentialCWords, offendingWords);
            idxSwitchCWords = Shuffle(1:length(switchWordsPool));
            switchWords = switchWordsPool(idxSwitchCWords(1:length(offendingWords)));
            
            idxOffendingWordsInSublist = ismember(thisSubList.words, offendingWords);
            idxSwitchWordsInSublist = ismember(thisSubList.words, switchWords);
            
            thisSubList.words(idxOffendingWordsInSublist) = switchWords;
            thisSubList.words(idxSwitchWordsInSublist) = offendingWords;
            
        end

        
        % create raw (unShuffled) AB lists       
        rawList.AB.cue = thisSubList.sounds(ismember(thisSubList.conds, [1:5]));
        rawList.AB.cond = thisSubList.conds(ismember(thisSubList.conds, [1:5]));
        rawList.AB.A = thisSubList.imgs(ismember(thisSubList.conds, [1:5]));
        rawList.AB.B = thisSubList.words(ismember(thisSubList.conds, [1:5]));
        
        rawList.AB.subsequentC = cell(size(rawList.AB.cond));
        rawList.AB.subsequentC(ismember(rawList.AB.cond, [1:3])) = thisSubList.words(ismember(thisSubList.conds, [6:8]));
        
        rawList.AB.subsequentACCue = cell(size(rawList.AB.cond));
        rawList.AB.subsequentACCue(ismember(rawList.AB.cond, [1:3])) = thisSubList.sounds(ismember(thisSubList.conds, [6:8])); 
           
        % create raw (unShuffled) AC lists    
        rawList.AC.cue = thisSubList.sounds(ismember(thisSubList.conds, [6:8]));
        rawList.AC.cond = thisSubList.conds(ismember(thisSubList.conds, [6:8]));
        rawList.AC.A = thisSubList.imgs(ismember(thisSubList.conds, [6:8]));
        rawList.AC.C = thisSubList.words(ismember(thisSubList.conds, [6:8]));
        rawList.AC.previousB = thisSubList.words(ismember(thisSubList.conds, [1:3]));
        rawList.AC.previousABCue = thisSubList.sounds(ismember(thisSubList.conds, [1:3]));
        
        % create raw (unShuffled) Sleep lists  
        rawList.Sleep.cue = thisSubList.sounds(ismember(thisSubList.conds, [2 5 6]));
        rawList.Sleep.cond = thisSubList.conds(ismember(thisSubList.conds, [2 5 6]));

        % create raw (unShuffled) Test lists  
        rawList.Test.cue = thisSubList.sounds(ismember(thisSubList.conds, [1:5])); %only 'B' cues are presented at test
        rawList.Test.cond = thisSubList.conds(ismember(thisSubList.conds, [1:5]));
        rawList.Test.A = thisSubList.imgs(ismember(thisSubList.conds, [1:5]));
        rawList.Test.correctAssociate = thisSubList.words(ismember(thisSubList.conds, [1:5]));
         
        % create permutation indices for shuffling
        withinABListShuffle = Shuffle(1:length(rawList.AB.cue));
        withinACListShuffle = Shuffle(1:length(rawList.AC.cue));
        rehShuffle.AB = Shuffle(1:length(rawList.AB.cue));
        rehShuffle.AC = Shuffle(1:length(rawList.AC.cue));
        sleepShuffle = Shuffle(1:length(rawList.Sleep.cue));
        testShuffle = Shuffle(1:length(rawList.Test.cue));
        
        % shuffle lists
        studyList.AB = indexAllFields(rawList.AB, withinABListShuffle);
        studyList.AC = indexAllFields(rawList.AC, withinACListShuffle);        
        rehList.AB = indexAllFields(rawList.AB, rehShuffle.AB); 
        rehList.AC = indexAllFields(rawList.AC, rehShuffle.AC);        
        sleepList = indexAllFields(rawList.Sleep, sleepShuffle);
        testList = indexAllFields(rawList.Test, testShuffle);
               
        cd (thePath.list);
        
        %save the lists
        
        saveMatchedLists(studyList.AB, nSubLists, i);
        saveLists(sleepList, 'sleepList', 1, i);
        saveLists(testList, 'testList', 1, i);

        end
    
end

function [  ] = saveMatchedLists(list, nSubLists, i)

for j=1:nSubLists
    subListIdx = 1+round(((j-1)/nSubLists)*length(list.cue)):round((j/nSubLists)*length(list.cue));
    
    %
    thisList = indexAllFields(list, subListIdx);
    thisListName = sprintf('studyList_AB_%s_%s', prepend(num2str(i)), prepend(num2str(j)));
    save(thisListName, 'thisList');
    
    %
    thisListName = sprintf('rehList_AB_%s_%s', prepend(num2str(i)), prepend(num2str(j)));
    thisList = shuffleAllFields(thisList);
    save(thisListName, 'thisList');
    
    %
    thisListName = sprintf('studyList_AC_%s_%s', prepend(num2str(i)), prepend(num2str(j)));
    thisList = shuffleAllFields(thisList);
    idxSubsequentCExists = cellfun(@isempty, thisList.subsequentC);
    thisList = subIdxAllFields(thisList,~idxSubsequentCExists);
    
    thisList.previousB = thisList.B;
    thisList.previousABCue = thisList.cue;
    thisList.C = thisList.subsequentC;
    thisList.cue = thisList.subsequentACCue;

    thisList = rmfield(thisList, 'B');
    thisList = rmfield(thisList, 'subsequentC');
    thisList = rmfield(thisList, 'subsequentACCue');
    
    save(thisListName, 'thisList');

    %
    thisListName = sprintf('rehList_AC_%s_%s', prepend(num2str(i)), prepend(num2str(j)));
    thisList = shuffleAllFields(thisList);
    
    save(thisListName, 'thisList');
end
end

function [  ] = saveLists(list, listname, nSubLists, i)

for j=1:nSubLists
    subListIdx = 1+round(((j-1)/nSubLists)*length(list.cue)):round((j/nSubLists)*length(list.cue));
    
    thisList = indexAllFields(list, subListIdx);
    thisStudyListName = sprintf('%s_%s_%s', listname, prepend(num2str(i)), prepend(num2str(j)));
    save(thisStudyListName, 'thisList');
end

end