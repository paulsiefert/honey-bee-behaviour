function I = ReadSEQIdxFrame(fid, fidIdx, frame, WorkerID)
endianType = 'ieee-le';
[readStart, imageBufferSize] = GetIdxFrameInfo(fidIdx, frame);
warning('off','MATLAB:imagesci:jpg:libraryMessage')
fseek(fid,readStart,'bof');
JpegSEQ = fread(fid,imageBufferSize,'uint8',endianType);

% Use two temp files to prevent fopen errors
if mod(frame,2)
    tempName = ['Temp\worker' num2str(WorkerID) '_tmp1.jpg'];
else
    tempName = ['Temp\worker' num2str(WorkerID) '_tmp2.jpg'];
end

tempFile = fopen(tempName,'w');
if tempFile < 0
    tempName = ['Temp\worker' num2str(WorkerID) '_tmp3.jpg'];
    tempFile = fopen(tempName,'w');
end
fwrite(tempFile,JpegSEQ);
fclose(tempFile);
I = imread(tempName);
return

function [readStart, imageBufferSize] = GetIdxFrameInfo(fidIdx, frame)
endianType = 'ieee-le';
if frame == 1
    readStart = 1028;
    fseek(fidIdx,8,'bof');
    imageBufferSize = fread(fidIdx,1,'ulong',endianType);
else
    readStartIdx = frame*24;
    fseek(fidIdx,readStartIdx,'bof');
    readStart = fread(fidIdx,1,'uint64',endianType)+4;
    %fseek(fidIdx,4,'cof');
    imageBufferSize = fread(fidIdx,1,'ulong',endianType);
end
return