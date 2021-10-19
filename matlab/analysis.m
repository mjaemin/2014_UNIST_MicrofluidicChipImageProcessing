function [Brightsum Filename] = analysis(overdir, representative)
% dirs = regexp(genpath('C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor'),['[^;]*'],'match')


%% 함수시작 (R2013a 버전 동작 확인) 수치 수정
global Column;
global Row;
global Magnitude;                    %반지름 배숫값수정

global MeanArea;
global MeanRadius;

%% 1. 파일 이름 불러오기
% overdir = 'C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\Left 1-4\'   %%상위 폴더명
% underdir = 'Left 1-4\'    %%하위 폴더명
listing = dir(fullfile(overdir, '*.tif'));
ImageNum = length(listing(not([listing.isdir])));        %%이미지의 갯수
[sx,sx] = sort([listing.datenum],'descend');        %%날짜 오름차순으로 최신이 나중에 나오도록
listing=listing(sx);

%%filename 에 처음 생성된 파일 부터 가장 최근 생성된 파일들의 이름을 나열
for i=1:ImageNum
    filename{i} = strcat(overdir, listing(i).name);
    Filename{i} = listing(i).name;
end

%% 2. 대표 이미지 정보 추출 및 마스크 그리기
% f = imread('C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\Left 1-4\Acquired-6.tif');
f=imread(representative);
[M, N, L] = size(f);

[L histed b degree stat MeanRadius MeanArea] = binarize(f);

%원그리기
figure(1)
subplot (2,1,1)
imshow(L);
hold on;
for k = 1: numel(stat)
%     rectangle('Position',[stat(x).Centroid(1)-MeanRadius,stat(x).Centroid(2)-MeanRadius,2*MeanRadius,2*MeanRadius],'Curvature',[1,1],'FaceColor','g');
    plot(stat(k).Centroid(1),stat(k).Centroid(2),'ro');
end

for k = 1:numel(stat)
    circle2(stat(k).Centroid(1), stat(k).Centroid(2),MeanRadius*Magnitude);
end
hold off;

%대표이미지 정보로 부터 마스크 출력
Mask=zeros(M,N);
for k=1:numel(stat)
    % Make the circle
    [xMat,yMat] = meshgrid(1:N,1:M);
    Mask = (sqrt((xMat-stat(k).Centroid(1)).^2 + (yMat-stat(k).Centroid(2)).^2)<=MeanRadius)|Mask;
end

%Degree 만큼 반시계 방향으로 마스크를 회전(수평으로 맞춤)
Mask = imrotate(Mask,degree,'nearest','crop');

%%테두리를 자른다.
for i=1:M
    if sum(Mask(1,:)) == 0
        Mask(1,:) = [];
    end
    
    if sum(Mask(end,:)) == 0
        Mask(end,:) = [];
    end
end

for j=1:N
    if sum(Mask(:,1)) == 0
        Mask(:,1) = [];
        
    end
    
    if sum(Mask(:,end)) == 0
        Mask(:,end) = [];
    end
        
end
subplot(2,1,2)
imshow(Mask);


%% 3. Template matching for other images / Extract averaged brightness of each mask

figure(2)
for i=1:ImageNum
    try
        figure(3)
    fprintf('%s 사진파일 연산중::: \n',listing(i).name);
    image2ori = imread(filename{i});
    image2ori = im2double(image2ori);
    [image2M image2N]=size(image2ori);
    [image2 histed b2 degree2] = binarize(image2ori);
    %Degree 만큼 반시계 방향으로 마스크를 회전(수평으로 맞춤)
    if abs(degree2) >= 10
        Maskrotated=Mask;
    else
        Maskrotated = imrotate(Mask,-degree2,'nearest','crop');
    end
    
    [MaskM MaskN MaskL] = size(Maskrotated);
    g = dftcorr(image2,Maskrotated);
    [I,J] = find(g==max(g(:)));
%     subplot(4,5,i)
    imshow(histed);
    imagesc(image2ori);
    hold on;
    stat = regionprops(Maskrotated,'centroid');
    %중심 그리기
    Maskrotated =bwlabel(Maskrotated,4);
    Brightsum(i,1)=i;
    for k = 1: numel(stat)
        [xMat,yMat] = meshgrid(1:image2N,1:image2M);
        [xMask, yMask] = find(Maskrotated==k);
        Brightsum(i,k+1)=0;
        
        for m = 1:length(xMask)
            Brightsum(i,k+1) = Brightsum(i,k+1) + image2ori(xMask(m)+I,yMask(m)+J);
        end       

%         length(xMask)
%         Brightsum(i,k+1)
        if size(xMask,1) ==0
            Brightsum(i,k+1)=0;
        else
            Brightsum(i,k+1) = Brightsum(i,k+1)*65535/length(xMask);
        end
        
        A=plot(stat(k).Centroid(1)+J,stat(k).Centroid(2)+I,'ro');
        set(A,'LineWidth',2);
        
        image2ori(round(stat(k).Centroid(2)+I),round(stat(k).Centroid(1)+J));
%         round(stat(k).Centroid(2)+I),round(stat(k).Centroid(1)+J)
%         circle2(stat(k).Centroid(1)+J, stat(k).Centroid(2)+I,MeanRadius*Magnitude);
xc = stat(k).Centroid(1)+J;
yc = stat(k).Centroid(2)+I;
r = MeanRadius*Magnitude;
x = r*sin(-pi:0.1*pi:pi) + xc;
y = r*cos(-pi:0.1*pi:pi) + yc;
fill(x, y, 'r', 'FaceAlpha', 0.35)
%         Brightness(i,k+1) = sum(sum(image2ori(xMask+I,yMask+J)))/length(xMask);
%         pause(0.01)
    end
     fprintf('%s 사진파일의 중심은요. \n',listing(i).name);
    pause(0.01)
    hold off;
    catch
        fprintf('%s 사진파일 에러남!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!. \n',listing(i).name);
        continue
    end
end