

osuSongDir='D:\Program Files (x86)\osu!\Songs\';

songList=dir(osuSongDir);

savefolder='D:\OSU\SongMat\';

% beatmapSetRange=[430000,445717];
mapper='Fycho';

for osuFolderIdx=3000:      length(songList)
    
    % Redirect to osufile folder.
    % Find *.osu in the folder
    
    %   OsuFolderStrcut structure is shown as follows
    %        name: '1 Kenji Ninuma - DISCO PRINCE'
    %      folder: 'C:\Users\Agony\AppData\Local\osu!\Songs'
    %        date: '08-8??-2017 10:29:39'
    %       bytes: 0
    %       isdir: 1
    %     datenum: 7.3692e+05
    
    osuFolderStruct=songList(osuFolderIdx);
    saveMatName=strcat(savefolder,osuFolderStruct.name,'.mat');
    osuFolder=strcat(osuSongDir,osuFolderStruct.name,'\');
    osuFileListStruct=dir(strcat(osuFolder,'*.osu'));
    
    %   osuFileListStruct(i) structure is shown as follows:
    %        name: 'Kenji Ninuma - DISCO??PRINCE (peppy) [Normal].osu'
    %      folder: 'C:\Users\Agony\AppData\Local\osu!\Songs\1 Kenji Ninuma - DISCO PRINCE'
    %        date: '08-8??-2017 10:36:04'
    %       bytes: 6697
    %       isdir: 0
    %     datenum: 7.3692e+05
    
    %   If there is no *.osu in the folder, jump to next folder
    
    if isempty(osuFileListStruct)
        continue
    else
        % Trying to find the largest file
        tempSaveBytes=0;
        tempSaveIdx=-1;
        for i=1:length(osuFileListStruct)
            if osuFileListStruct(i).bytes>tempSaveBytes
                tempSaveBytes=osuFileListStruct(i).bytes;%������û��
                tempSaveIdx=i;
            end
        end
    end
    
    % Here we get the directory and filename of the osu file
    
    osufilename=strcat(osuFolder,osuFileListStruct(tempSaveIdx).name);
    try
        s=osuFileRead(osufilename);
    catch ME
        ME
        disp(osuFolder)
        disp(strcat(osuFileListStruct(tempSaveIdx).name,' cannot be processed'));
        fclose all;
        
    end
    try
        BeatmapSetID=str2double(s.Metadata.BeatmapSetID);        
    catch
        try
           name=osuFolderStruct.name;
           BeatmapSetID=textscan(osuFolderStruct.name,'%d ');
           BeatmapSetID=BeatmapSetID{1}(1);
        catch
            continue
        end
    end
    
    %----------------------------------------
    %-------------selecting------------------
    %----------------------------------------
    try
        if ~strcmp(s.Metadata.Creator,mapper)
            continue
        end
    catch
        continue
    end
    
    try
        
        % Commented at 2017.8.27 by Agony.
        % osufilename=[dir,...
        %     'Daisuke Achiwa - BASARA (100pa-) [BASARA].osu'];
        % songfile=[dir,...
        %     'BASARA.mp3'];
        
        
        disp(['Operating osufile: ',osuFolderStruct.name, '. Progress: ',num2str(osuFolderIdx-2),...
            ' of ',num2str(length(songList)-2)])
        % songfilename and directory is get at here
        songfilename=s.General.AudioFilename;
        songfile=strcat(osuFolder,songfilename);
        
        Ts=getRhythmPoints(s);
        osuObj=osuObjectParser(s);
        osuDataInput = getOsuDataInput(s,songfile);
        osuDataTarget = getOsuDataTarget(s);
        
        target=osuDataTarget;
        input=osuDataInput;
        [input1,target1]=regularizeDataInputTarget(input,target);        
        save(saveMatName,'s','Ts','input','input1','target1','osuFolder');
        disp('sucess!')
    catch
        
        disp('Process Abort!!')
    end
    
end