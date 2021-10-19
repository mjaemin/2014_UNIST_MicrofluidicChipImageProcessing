imageanalysis('C:\Users\Unist_dogyeong\Desktop\2014.08.28 OD 2 - Fluid patterning comparison\','C:\Users\Unist_dogyeong\Desktop\2014.08.28 OD 2 - Fluid patterning comparison\OD2\Acquired.tif')
clear all;
clc;

image=imread('C:\Users\Unist_dogyeong\Desktop\JM\Dropbox\2014 summer research\2014.08.28 OD 2 - Fluid patterning comparison\OD half\Acquired-2.tif');

% [Mask B]=binarize(image);
% figure(3)
% imshow(Mask)
% L=bwlabel(Mask,4);
% max(max(L))
% B

histed=intrans(image,'stretch',mean2(im2double(image)),0.9);
histed=histeq(histed);
h=fspecial('gaussian',70,15);
gh=imfilter(histed,h,'replicate');
gh=im2bw(gh,1.5*graythresh(gh));

L=bwlabel(gh,4);
% figure(2)
imshow(gh)
%오브젝트 개수 세기
num=max(max(L)); %오브젝트 개수
% ncol=input('Enter the number of colomuns : ');   %가로개수
% nraw=input('Enter the number of raws : ');   %세로개수
% n=ncol*nraw;    %입력값 총 개수
n=8;
% fprintf('%f개로 걸러내겠습니다! : %f\n',n)


%라벨링해서 n개보다 많으면 n개가 될때까지 가장 작은 면적을 가진 라벨링 없앰
for i=1:num
    noe(i)= sum(sum(L==i));     %Number of dots(area)
end
noesort=sort(noe);

NumberOfRemoval=0;
if n < num
    for k=1:num-n   %가장 작은 면적을 가진 라벨부터
        label=find(noe==noesort(k));   %index of min
        
        for i=1:size(L,1)
            for j=1:size(L,2)
                if L(i,j) == label
                    L(i,j)=0;
                end
            end
        end
        NumberOfRemoval=NumberOfRemoval+1;    
    end
    MeanArea=sum(noesort(num-n+1:end))/n;
    MeanRadius=sqrt(MeanArea/pi);
else
    MeanArea=sum(noesort)/num;
    MeanRadius=sqrt(MeanArea/pi);
end

% Ibw = im2bw(L);
% Ilabel = bwlabel(Ibw);
% stat = regionprops(Ilabel,'centroid');

L = bwlabel(L);
stat = regionprops(L,'centroid');

%Least-squares fit 으로 샘플 이미지 점들의 평균 기울기를 구함
%Initializing
xavg=0;
bnom=0;
bdenom=0;

%Compute x-average
for k=1:numel(stat)
    xavg=xavg+stat(k).Centroid(1);
end
xavg=xavg/numel(stat);

%Compute b through least sqaures fit
for k=1:numel(stat)
    bnom=bnom+stat(k).Centroid(2)*(stat(k).Centroid(1)-xavg);
    bdenom=bdenom+stat(k).Centroid(1)*(stat(k).Centroid(1)-xavg);
end
b=bnom/bdenom;
degree=atand(b);
Mask=L;
figure(4)
imshow(Mask)