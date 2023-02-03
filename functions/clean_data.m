function [signalCleaned, time] = clean_data(folders, commonPath, filePattern, filterBand, freq)
    for iFolders = 1:length(folders)
        rootDir = fullfile(commonPath, folders(iFolders).name, filePattern);
        folderPath = fullfile(commonPath, folders(iFolders).name);
        fileNames = dir(rootDir);

        for iFiles = 1:length(fileNames)

            [signalFiltered, time] = filterSignal(folderPath, fileNames(iFiles).name, filterBand, freq);
            signalCleaned = slider(signalFiltered, time, 300, fileNames(iFiles).name);
            save(strcat(folderPath,'\c_', erase(fileNames(iFiles).name, '.resp'),'.mat' ), 'signalCleaned', 'time')
        end
    end
end