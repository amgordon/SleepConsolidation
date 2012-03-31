
function theData = SC_Study(S, studyBlock)

% This function accepts a structure S, then loads the images and runs the expt
% Run AG4.m first, otherwise thePath will be undefined.
% Written by Alan Gordon, 2/7/2012
%

% Read in the list
cd(S.thePath.list);

list = load(S.sleep.listName);
list = list.thisList;

listLength = length(list.cond);

theData = list;


scrsz = get(0,'ScreenSize');

% Diagram of a trial

soundTime = 1.5;
interTrialTime = 1.5;
getReadyTime = .5;
leadinTime = 4;

Screen(S.Window,'FillRect', S.screenColor);
Screen(S.Window,'Flip');
cd(S.thePath.stim);

for l=1:listLength
    wavfilenameCue = fullfile(S.thePath.stim, theData.cue{l});
    [yCue, cue.freq{l}] = wavread(wavfilenameCue);
    cue.wavedata{l} = yCue(:,1)';
    cue.nrchannels{l} = size(cue.wavedata,1); % Number of rows == number of channels.
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
    theData.cueResp{preall} = [];
    theData.cueRespRT{preall} = [];
    theData.ITIResp{preall} = [];
    theData.ITIRespRT{preall} = [];
end

% for the first block, display instructions

% get ready screen
%Screen(S.Window, 'DrawTexture', blank);
message = 'Press g to begin!';
[hPos, vPos] = SCcenterText(S.Window,S.screenNumber,message);
Screen(S.Window,'DrawText',message, hPos, vPos, S.textColor);
Screen(S.Window,'Flip');

% give the output file a unique name
cd(S.sDataDir);
matName = ['SC_sleep_sub' num2str(S.sNum), '_date_' S.sName 'out.mat'];
checkEmpty = isempty(dir (matName));
suffix = 1;
while checkEmpty ~=1
    suffix = suffix+1;
    matName = ['SC_sleep_sub' num2str(S.sNum), '_' S.sName 'out(' num2str(suffix) ').mat'];
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
    
    % Get Ready
    goTime = getReadyTime;
    Screen(S.Window, 'FillOval', S.fixColor, S.fixRect);
    Screen(S.Window,'Flip');
    SCrecordKeys(ons_start,goTime,S.boxNum, [], S.terminationCode);  % not collecting keys, just a delay
    
    % Cue Sound
    S.pahandle = PsychPortAudio('Open', [], [], 0, cue.freq{Trial}, cue.nrchannels{Trial});
    soundStartTime = GetSecs;
    goTime = goTime + soundTime;
    thisSound = cue.wavedata{Trial};
    soundEndTime = soundStartTime+soundTime;
    PsychPortAudio('FillBuffer', S.pahandle, thisSound);
    PsychPortAudio('Start', S.pahandle, 1, 0, 1, soundEndTime);
    remainingTime = goTime - (GetSecs - soundStartTime);
    [theData.cueResp{Trial}, theData.cueRespRT{Trial}] = SCrecordKeys(ons_start,remainingTime,S.boxNum, [], S.terminationCode);
        
    % ITI
    goTime = goTime + interTrialTime;
    Screen(S.Window, 'FillOval', S.fixColor2, S.fixRect);
    Screen(S.Window,'Flip');
    [theData.ITIResp{Trial}, theData.ITIRespRT{Trial}] = SCrecordKeys(ons_start,goTime,S.boxNum, [], S.terminationCode); 
 
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

% ------------------------------------------------
Priority(0);
