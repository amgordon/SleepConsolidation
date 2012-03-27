
function SCrun(thePath)

% Written by Alan M. Gordon, Stanford Memory Lab
% March 14, 2012



if nargin == 0
    error('Must specify thePath')
end

S.thePath = thePath;
S.sName = input('Enter date (e.g. ''11Feb11'') ','s');
S.sNum = input('Enter subject number: ');

testType = -1;
S.mirrorlr = -1;

while ~ismember(testType,[0,1,2,3])
    testType = input('Which task?  Pr[0] Tr[1] Sl[2] Te[3]? ');
end

S.eeg = 0;
while ~ismember(S.eeg,[1,2])
    S.eeg = input('In eeg environment [1] or behavioral [2] ? ');
end


S.boxNum = SCgetKeyboardNumber;  % buttonbox
S.kbNum = SCgetKeyboardNumber; % keyboard

S.terminationCode = 'ESCAPE'; %terminate if escape is pressed.
S.blockNum = 1;

listenChar(2);

%-------------------------------
HideCursor;

% Screen commands
S.screenNumber = 0;
S.screenColor = 255;
S.textColor = 0;
S.fixColor = [255 0 0];
S.fixColor2 = [0 255 0];
[S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow', S.screenColor, [], 32);
S.txtYPos = 575;

sz = get(0, 'screensize');
S.scrsz.width = sz(3);
S.scrsz.height = sz(4);
S.fixRadius = 5;
S.fixRect = CenterRect([0 0 2*S.fixRadius 2*S.fixRadius], Screen(S.Window, 'Rect'));
[S.hCenter, S.vCenter] = SCcenterText(S.Window,S.screenNumber,'centeringDummyText');

S.sDataDir = fullfile(thePath.data, [S.sName '_' num2str(S.sNum)] );

if ~exist(S.sDataDir)
   mkdir(S.sDataDir); 
end

Screen('TextSize', S.Window, 32);
Screen('TextStyle', S.Window, 1);
S.on = 1;  % Screen now on

S.nLists = 40;
S.listNum = 1+mod(S.sNum-1, S.nLists);

    
if testType == 0
    saveName = ['SC_PracStudy_' S.sName '_' num2str(S.sNum) '.mat'];
    
    
    S.study.listName = fullfile(S.thePath.list, 'practiceStudyList.mat');
    learnDataAB(S.blockNum) = SC_PracStudy(S);
    
    S.rehearse.listName = fullfile(S.thePath.list, 'practiceRehList.mat');
    rehDataAB(S.blockNum) = SC_PracRehearse(S);
    
    checkEmpty = isempty(dir (saveName));
    suffix = 1;
    
    while checkEmpty ~=1
        suffix = suffix+1;
        saveName = ['SC_Practice_' S.sName '_' num2str(S.sNum) '(' num2str(suffix) ')' '.mat'];
        checkEmpty = isempty(dir (saveName));
    end
    
    eval(['save ' saveName]);
    
    
    
elseif testType == 1
    saveName = ['SC_Study_' S.sName '_' num2str(S.sNum) '.mat'];
    
    for i=S.blockNum:10
        S.study.listName = sprintf('studyList_AB_%s_%s.mat', prepend(num2str(S.listNum)), prepend(num2str(i)));
        learnDataAB(S.blockNum) = SC_Study(S);
        
        S.rehearse.listName = sprintf('rehList_AB_%s_%s.mat', prepend(num2str(S.listNum)), prepend(num2str(i)));
        rehDataAB(S.blockNum) = SC_Rehearse(S);
        
        S.study.listName = sprintf('studyList_AC_%s_%s.mat', prepend(num2str(S.listNum)), prepend(num2str(i)));
        learnDataAC(S.blockNum) = SC_Study(S);
        
        S.rehearse.listName = sprintf('rehList_AC_%s_%s.mat', prepend(num2str(S.listNum)), prepend(num2str(i)));
        rehDataAC(S.blockNum) = SC_Rehearse(S);
        
        checkEmpty = isempty(dir (saveName));
        suffix = 1;
        
        while checkEmpty ~=1
            suffix = suffix+1;
            saveName = ['SC_Study_' S.sName '_' num2str(S.sNum) '(' num2str(suffix) ')' '.mat'];
            checkEmpty = isempty(dir (saveName));
        end
        
        eval(['save ' saveName]);
    end
    
elseif testType == 2
    saveName = ['SC_Sleep_' S.sName '_' num2str(S.sNum) '.mat'];
    
    S.sleep.listName = sprintf('sleepList_%s_%s.mat', prepend(num2str(S.listNum)), prepend(num2str(S.blockNum)));
    SleepData = SC_SleepCue(S);
    
    checkEmpty = isempty(dir (saveName));
    suffix = 1;
    
    while checkEmpty ~=1
        suffix = suffix+1;
        saveName = ['SC_Sleep_' S.sName '_' num2str(S.sNum) '(' num2str(suffix) ')' '.mat'];
        checkEmpty = isempty(dir (saveName));
    end

    eval(['save ' saveName]);
    % full file saved here


elseif testType == 3
    saveName = ['SC_Test_' S.sName '_' num2str(S.sNum) '.mat'];
    
    S.test.listName = sprintf('testList_%s_%s.mat', prepend(num2str(S.listNum)), prepend(num2str(S.blockNum)));
    TestData.block = SC_Test(S);
    
    checkEmpty = isempty(dir (saveName));
    suffix = 1;

    while checkEmpty ~=1
        suffix = suffix+1;
        saveName = ['SC_Test_' S.sName '_' num2str(S.sNum) '(' num2str(suffix) ')' '.mat'];
        checkEmpty = isempty(dir (saveName));
    end

    eval(['save ' saveName]);
    % Output file for each block is saved within AG4test; full file saved
    % here
end

message = 'End of script. Press any key to exit.';

Screen(S.Window,'DrawText',message, S.hCenter, S.vCenter, 0);
Screen(S.Window,'Flip');

listenChar(1);
pause;

Screen('CloseAll');

