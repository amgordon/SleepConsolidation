
function theData = SC_Rehearse(S)

% This function accepts a structure S, then loads the images and runs the expt
% Run AG4.m first, otherwise thePath will be undefined.
% Written by Alan Gordon, 2/7/2012
%

% Read in the list
cd(S.thePath.list);

list = load(S.rehearse.listName);
list = list.thisList;

listLength = length(list.cond);

theData = list;

scrsz = get(0,'ScreenSize');

if isfield(theData, 'B')
    S.wordType = 'B';
else
    S.wordType = 'C';
end

% Diagram of trial
soundTime = 2.5;
textTime = 2.5;
interTrialTime = 1;
leadinTime = 4;
blankTime = .25;
answerTime = 5;

Screen(S.Window,'FillRect', S.screenColor);
Screen(S.Window,'Flip');

%preload sounds
cd(S.thePath.stim);
for L=1:listLength
    wavfilenameCue = fullfile(S.thePath.stim, theData.cue{L});
    [yCue, cue.freq{L}] = wavread(wavfilenameCue);
    cue.wavedata{L} = yCue(:,1)';
    cue.nrchannels{L} = size(cue.wavedata,1); % Number of rows == number of channels.
end

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


% study stims: text cannot be preloaded, so stims will be generated on the
% fly

% preallocate:
trialcount = 0;
for preall = 1:listLength
    theData.onset(preall) = 0;
    theData.dur(preall) =  0;
end

% display instructions
ins_txt =  sprintf('This is a Rehearsing round. \n\n This round is designed to help you learn the trios you encountered in the previous round better.  During each trial of this phase of the experiment, you will hear a sound and see an image and the first letter of a word.  \n\n Your job is to type in the rest of the word that you remember associating with that sound and picture.  After you type your response and hit ''enter,'' the correct answer will appear on the screen.');
DrawFormattedText(S.Window, ins_txt, 'center', 'center', S.textColor, 75, [], [], 1.5);
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
matName = ['SC_Rehearse' num2str(S.sNum), '_date_' S.sName 'out.mat'];
checkEmpty = isempty(dir (matName));
suffix = 1;
while checkEmpty ~=1
    suffix = suffix+1;
    matName = ['SC_Rehearse' num2str(S.sNum), '_' S.sName 'out(' num2str(suffix) ').mat'];
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
    
    
    % Cue Sound
    S.pahandle = PsychPortAudio('Open', [], [], 0, cue.freq{Trial}, cue.nrchannels{Trial});
    soundStartTime = GetSecs;
    %goTime = soundTime;
    thisSound = cue.wavedata{Trial};
    soundEndTime = soundStartTime+soundTime;
    PsychPortAudio('FillBuffer', S.pahandle, thisSound);
    PsychPortAudio('Start', S.pahandle, 1, 0, 1, soundEndTime);
    %remainingTime = goTime - (GetSecs - soundStartTime);
    %SCrecordKeys(ons_start,remainingTime,S.boxNum); % not collecting keys, just a delay
    
    % Image
    thisImage = imgSet{Trial};
    Screen(S.Window, 'DrawTexture', thisImage);
    Screen(S.Window,'Flip');
    
    % User types response
    startTypingTime = GetSecs;
    initial = theData.(S.wordType){Trial}(1);
    typedText = SC_GetEchoString_withImg(S.Window, initial, S.hCenter, S.txtYPos, S.textColor, thisImage);
    durTypingTime = GetSecs - startTypingTime;
    theData.typedResp{Trial} = [initial typedText];
    theData.typedRT(Trial) = durTypingTime;
     
    % blank space
    Screen(S.Window,'Flip');
    goTime = blankTime + durTypingTime;
    Screen(S.Window, 'FillOval', S.fixColor, S.fixRect);
    Screen(S.Window,'Flip');
    SCrecordKeys(ons_start,goTime,S.boxNum, [], S.terminationCode);  % not collecting keys, just a delay

    % Text
    Screen(S.Window,'Flip');
    goTime = goTime  + textTime;
    stim = theData.(S.wordType){Trial};
    DrawFormattedText(S.Window,stim,'center','center',S.textColor);
    Screen(S.Window,'Flip');
    SCrecordKeys(ons_start,goTime,S.boxNum, [], S.terminationCode); % not collecting keys, just a delay
    
    % ITI  
    goTime = goTime + interTrialTime;
    Screen(S.Window, 'FillOval', S.fixColor, S.fixRect);
    Screen(S.Window,'Flip');
    SCrecordKeys(ons_start,goTime,S.boxNum, [], S.terminationCode);  % not collecting keys, just a delay
    
    theData.dur(Trial) = GetSecs - ons_start;  %records precise trial duration
    
    % Close sound file
    PsychPortAudio('Close', S.pahandle);
    save(matName, 'theData', 'S')

    fprintf('%d\n',Trial);
end


clear cue;    
cmd = ['save ' matName];
eval(cmd);


Screen(S.Window,'FillRect', S.screenColor);	% Blank Screen
Screen(S.Window,'Flip');
Screen('Close');
% ------------------------------------------------
Priority(0);
