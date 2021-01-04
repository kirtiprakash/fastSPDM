function M = Read3DtifFast( FileTif, startframe, endframe)
%READ3DTIF2FAST Summary of this function goes here
%   Detailed explanation goes here

if nargin<3
    endframe=Inf;
end
if nargin<2
    startframe=1;
end

InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;

NumberImages=length(InfoImage);

if startframe>NumberImages
    startframe=NumberImages;
end
if endframe<startframe
    endframe=startframe;
end
if (endframe-startframe+1)>NumberImages
    endframe=NumberImages;
end

NumberImages=endframe-startframe+1;

M=zeros(nImage,mImage,NumberImages,'uint16');

TifLink = Tiff(FileTif, 'r');
numstringlength=0;
for j=1:NumberImages
    i=startframe+j-1;
    if mod(i,50)==0;
        numstring=num2str(i);
        for s=1:numstringlength;
            fprintf('\b')
        end
        fprintf(numstring)
        numstringlength=length(numstring);
    end
   TifLink.setDirectory(i);
   M(:,:,j)=TifLink.read();
end
fprintf('\n')
TifLink.close();

end

