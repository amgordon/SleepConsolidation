
function theData = SC_Test(S)

% This function accepts a structure S, then loads the images and runs the expt
% Run AG4.m first, otherwise thePath will be undefined.
% Written by Alan Gordon, 2/7/2012
%

% Read in the list
cd(S.thePath.list);

list = load(S.test.listName);
list = list.thisList;

listLength = length(list.cond);

theData = list;

scrsz = get(0,'ScreenSize');

% Diagram of trial
interTrialTime = .8;
leadinTime = 4;

Screen(S.Window,'FillRect', S.screenColor);
Screen(S.Window,'Flip');
cd(S.thePath.stim);

%preload images
cd(S.thePath.SVLO);
for l=1:listLength
    fileName  = theData.A{l};
    pic = imread(fileName);
    imgSet{l} = Screen(S.Window, 'MakeTexture', pic);
end

% Load fixation
fileName = fullfile(S.thePath.stim, 'fix.jpg');
pic = imread(fileName);
fix = Screen(S.Window,'MakeTexture', pic);

% Load blank
fileName = fullfile(S.thePath.stim, 'blank.jpg');
pic = imread(fileName);
blank = Screen(S.Window,'MakeTexture', pic);

cd(S.thePath.stim);


% preallocate:
trialcount = 0;
for preall = 1:listLength
    theData.onset(preall) = 0;
    theData.dur(preall) =  0;
    theData.typedResp{preall} = [];
    theData.typedRespRT{preall} = [];
end

% display instructions
ins_txt =  sprintf('During each trial of this phase of the experiment, you see a picture, and the first letter of a word that was associated with this sound. Your job is to type the rest of the word.');
DrawFormattedText(S.Window, ins_txt,'center','center',S.textColor,75,[],[],1.5);
Screen('Flip',S.Window);
SCgetKey('g',S.kbNum);


% get ready screen
%Screen(S.Window, 'DrawTexture', blank);
message = 'Press g to begin!';
[hPos, vPos] = SCcenterText(S.Window,S.screenNumber,message);
Screen(S.Window,'DrawText',message, hPos, vPos, S.textColor);
Screen(S.Window,'Flip');

% give the output file a unique name
cd(S.sDataDir);
matName = ['SC_test_sub' num2str(S.sNum), '_date_' S.sName 'out.mat'];
checkEmpty = isempty(dir (matName));
suffix = 1;
while checkEmpty ~=1
    suffix = suffix+1;
    matName = ['SC_test_sub' num2str(S.sNum), '_' S.sName 'out(' num2str(suffix) ').mat'];
    checkEmpty = isempty(dir (matName));
end


% Present test trials
goTime = 0;

%  initiate experiment and begin recording time...
% start timing/trigger

SCgetKey('g',S.kbNum);
startTime = GetSecs;

Priority(MaxPriority(S.Window));

% Fixation
goTime = goTime + leadinTime;

Screen(S.Window, 'FillOval', S.fixColor, S.fixRect);
Screen(S.Window,'Flip');

SCrecordKeys(startTime,goTime,S.kbNum, [], S.terminationCode);  % not collecting keys, just a delay

for Trial = 1:listLength
    
    trialcount = trialcount + 1;
    ons_start = GetSecs;
    
    theData.onset(Trial) = GetSecs - startTime; %precise onset of trial presentation    
    

    % Image
    thisImage = imgSet{Trial};
    Screen(S.Window, 'DrawTexture', thisImage);
    Screen(S.Window,'Flip');
    
    % User types response
    startTypingTime = GetSecs;
    initial = theData.correctAssociate{Trial}(1);
    typedText = SC_GetEchoString_withImg(S.Window, initial, S.hCenter, S.txtYPos, S.textColor, thisImage);
    durTypingTime = GetSecs - startTypingTime;
    theData.typedResp{Trial} = [initial typedText];
    theData.typedRT(Trial) = durTypingTime;
    
    % ITI
    Screen(S.Window,'Flip');
    goTime = interTrialTime;
    Screen(S.Window, 'FillOval', S.fixColor, S.fixRect);
    Screen(S.Window,'Flip');
    SCrecordKeys(ons_start,goTime,S.boxNum, [], S.terminationCode);  % not collecting keys, just a delay
    
    theData.dur(Trial) = GetSecs - ons_start;  %records precise trial duration
    
    % Close sound file
    save(matName, 'theData', 'S');

    
    fprintf('%d\n',Trial);
end


    
cmd = ['save ' matName];
eval(cmd);


Screen(S.Window,'FillRect', S.screenColor);	% Blank Screen
Screen(S.Window,'Flip');
Screen('Close');
% ------------------------------------------------
Priority(0);
