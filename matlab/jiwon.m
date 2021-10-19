function jiwon
clear all;
close all;
clc;

%% 지원이 형이 건드릴 부분
% 26번 라인, overdir 에다가 사진파일들이 있는 폴더의 경로를 입력
% 41번 라인, imread 에다가 대표적인 이미지 경로와 파일이름을 입력
% F5번 클릭으로 함수 동작
% figure(5)창에서 대략 0.5초마다(컴성능에 따라 다름, 수정가능) 첫 파일부터 마지막 파일까지 중심점을 잡을 겁니다.
% 중간에 취소하고 싶으면 매트랩 커맨드 창에, 왼쪽 Ctrl + C
% 파일 순서는 파일 생성 날짜 시간 순서(초단위)로 했습니다. 동일한 시간대(초단위까지)에 생성된 사진 파일이 몇 있더라고요.
% 가작성된 프로그램입니다. 프로그램이 좀 지저분한데, 최적화 및 그래픽인터페이스는 차차 진행하겠습니다.

%% 기본원리
% 1. 가장잘나온 사진(대표)상의 중심(원이라 가정, 8개)사이의 거리, 평균 반지름 등의 정보를 입력받고
% 2. 해당 폴더내의 파일을 순서대로 읽어서, filename(i), 기울어짐 정도에 맞춰 대표이미지 기울기를 맞춤
% 3. Template matching 을 이용하여 두 이미지가 가장 장 매칭이 되는 지점을 찾아 표시
% 4. (미진행) filename(i)의 8개 중심에서 평균반지름*1.1배(수정)의 반지름을 가진 원을 그려서
% 5. (미진행) 좌측 윗줄부터 [1 2 3 4 ; 5 6 7 8] 번 마스크를 만듦
% 6. (미진행) filename(i)에서 마스크 영역 1번부터 8번까지 평균 밝기를 계산
% 7. (미진행) 엑셀파일로 출력 [finlename(i) 마스크(j) 평균밝기 평균면적]

%% 함수시작 (R2013a 버전 동작 확인)
%%파일 이름 불러오기
overdir = 'C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\Left 1-4\'   %%상위 폴더명
% underdir = 'Left 1-4\'    %%하위 폴더명
listing = dir(fullfile(overdir, '*.tif'));
ImageNum = length(listing(not([listing.isdir])));        %%이미지의 갯수

[sx,sx] = sort([listing.datenum],'descend');        %%날짜 오름차순으로 최신이 나중에 나오도록
listing=listing(sx);
listing.name

%%filename 에 처음 생성된 파일 부터 가장 최근 생성된 파일들의 이름을 나열
for i=1:ImageNum
    filename{i} = strcat(overdir, listing(i).name);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f=imread('C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\Left 1-4\Acquired-6.tif');
%f=imread('C:\Users\moon\Dropbox\연구장학생\자율미션\영상\2.jpg');
[M,N,L]=size(f);

%일반 평활화
histed=histeq(f);

%콘트라스트-스트레칭 변환
histed2=intrans(f,'stretch',mean2(im2double(f)),0.9);

%검은색 검 노이즈 제거
% fp=spfilt(histed2,'max',3,3);
%흰색 점 노이즈의 경우
% fp=spfilt(histed2,'min',3,3);

%평활화
% p = twomodegauss(0.15, 0.05, 0.75, 0.05, 1, 0.07, 0.002)
% histed2=histeq(f,p);
histed2=histeq(histed2);
%필터링 h 값
% h=fspecial('gaussian',30,15);
h=fspecial('gaussian',50,15);

%가우시안 필터링
gh1=imfilter(histed2,h,'replicate');

%그레이 쓰레시홀드 문턱치값으로 영상 이진화
gh=im2bw(gh1,1*graythresh(gh1));

%라벨링
L=bwlabel(gh,4);

%오브젝트 개수 세기
num=max(max(L)); %오브젝트 개수
ncol=4; %%input('Enter the number of colomuns : ');   %가로개수
nraw=2; %%input('Enter the number of raws : ');   %세로개수
n=ncol*nraw;    %입력값 총 개수
fprintf('%f개로 걸러내겠습니다! \n',n)


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


%원그리기

figure(1)
imshow(L); hold on;
for k = 1: numel(stat)
%     rectangle('Position',[stat(x).Centroid(1)-MeanRadius,stat(x).Centroid(2)-MeanRadius,2*MeanRadius,2*MeanRadius],'Curvature',[1,1],'FaceColor','g');
    plot(stat(k).Centroid(1),stat(k).Centroid(2),'ro');
end


%%원 좌표 그리기
figure(3)
accum = 1;
for k=1:numel(stat)
    [x y] = getmidpointcircle(stat(k).Centroid(1), stat(k).Centroid(2), MeanRadius);
    Maskpixel(accum : accum + size(x) - 1,1) = x;
    Maskpixel(accum : accum + size(y) - 1,2) = y;
    accum = accum + size(x);
end
plot(Maskpixel(:,1),Maskpixel(:,2), 'r', 'LineWidth', 2);

%원그리기
Mask=zeros(M,N);
for k=1:numel(stat)
    % Make the circle
    [xMat,yMat] = meshgrid(1:N,1:M);
    Mask = (sqrt((xMat-stat(k).Centroid(1)).^2 + (yMat-stat(k).Centroid(2)).^2)<=MeanRadius)|Mask;
    
end
figure(2)
imshow(Mask)
%%%%    Least-squares fit 으로 샘플 이미지 점들의 평균 기울기를 구함
%Initializing
xavg=0;
bnom=0;
bdenom=0;

%Compute x-average
for k=1:numel(stat)
    xavg=xavg+stat(k).Centroid(1);
end
xavg=xavg/numel(stat);

%6개의 경우 7개인 경우 8개인 경우 모두 나누기

%Compute b through least sqaures fit
for k=1:numel(stat)
    bnom=bnom+stat(k).Centroid(2)*(stat(k).Centroid(1)-xavg);
    bdenom=bdenom+stat(k).Centroid(1)*(stat(k).Centroid(1)-xavg);
end
b=bnom/bdenom;
degree=atand(b);

%Degree 만큼 반시계 방향으로 마스크를 회전(수평으로 맞춤)
% Mask = imrotate(Mask,degree,'nearest','crop');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%이미지2도 똑같이 기울기를 구해서 기울기만큼 회전시켜 수평으로 맞춤
%마스크 이미지를 잘라서 템플릿 매칭을 하여 최적 위치를 찾는다
%이미지를 마스킹하여 1~8번 라벨링을 한다.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%새로운 이미지2를 불러옴
[image2 b2 degree2] = binarize(filename{24}); %5번째가 7개 덩어리짜리임

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%마스크의 기울기에서 이미지2의 기울기를 뺀 만큼 마스크를 회전시켜 이미지2와 마스크가 평행하도록

rotatedegree = degree - degree2;
%Degree 만큼 반시계 방향으로 마스크를 회전(수평으로 맞춤)
Maskrotated = imrotate(Mask,rotatedegree,'nearest','crop');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%바이너리화
% Maskrotated=im2bw(Maskrotated);
% image2=im2bw(image2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

g = dftcorr(image2,Maskrotated);
[I,J] = find(g==max(g(:)));

% image2rotate = imrotate(image2,degree2,'nearest','crop');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%마스크 테두리를 자른다
%마스크 기울기-이미지2 기울기 의 각도만큼 마스크를 돌려서 템플릿 매칭

%이미지2의 경계 픽셀을 구한다
% image2=binarizetemp(image2);
% boundaries = bwboundaries(image2);
% numberOfBoundaries = size(boundaries);
% Mask_boundaries = bwboundaries(Mask);
% accum = 1;
%  for k = 1: numberOfBoundaries
%      thisBoundary = boundaries{k};
%      image2pixel(accum : accum + size(boundaries{k}(:,2)) - 1,1) = boundaries{k}(:,2);
%      image2pixel(accum : accum + size(boundaries{k}(:,1)) - 1,2) = boundaries{k}(:,1);
%      accum = accum + size((boundaries{k}(:,2)));
%  end
% size(Maskpixel);
% size(image2pixel);
%마스크(Maskpixel)를 다음 장의 이미지2(image2pixel)에 맞게 회전함
% [d,Mask2,tr] = procrustes(image2pixel,Maskpixel,'Scaling',false);


figure(4)
subplot(2,2,1)
imshow(image2);

subplot(2,2,2)
imshow(Maskrotated);

subplot(2,2,3)
imshow(g);
hold on;
plot(J,I,'rx');
% imshow(Mask_boundaries);

subplot(2,2,4)
imshow(image2);
stat = regionprops(Maskrotated,'centroid');
%원그리기
hold on;
for k = 1: numel(stat)
%     rectangle('Position',[stat(x).Centroid(1)-MeanRadius,stat(x).Centroid(2)-MeanRadius,2*MeanRadius,2*MeanRadius],'Curvature',[1,1],'FaceColor','g');
    plot(stat(k).Centroid(1)+J,stat(k).Centroid(2)+I,'ro');
end
hold off;

% plot(image2pixel(:,1), image2pixel(:,2), 'g', 'LineWidth', 2);

figure(5)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 이미지 하나씩 불러오기
for i=1:ImageNum
    [image2 b2 degree2] = binarize(filename{i});
    rotatedegree = degree - degree2;
    %Degree 만큼 반시계 방향으로 마스크를 회전(수평으로 맞춤)
    Maskrotated = imrotate(Mask,rotatedegree,'nearest','crop');
    g = dftcorr(image2,Maskrotated);
    [I,J] = find(g==max(g(:)));
    imshow(image2);
    stat = regionprops(Maskrotated,'centroid');
    %원그리기
    hold on;
    for k = 1: numel(stat)
        plot(stat(k).Centroid(1)+J,stat(k).Centroid(2)+I,'ro');
    end
    hold off;
    fprintf('%f번째 사진파일의 중심은요. \n',i);
    pause(0.3);    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % 
% % for k=1:n
% %     label=find(noe==noesort(num+1-k));
% %     4
% 
% %     for i=1:size(L,1)
% %         for j=1:size(L,2)
% %             if L(i,j) == label
% %                 Layers(i,j,k)=k;
% %             end
% %         end
% %     end
% % end
% 
% 
% 
% % 대표이미지 저장, 템플릿 매칭과 컨볼루젼을 이용해서 같은 영역대 찾기
% % 
% % 
% 
% % %폴리곤
% % [x,y]=minperpoly(gh,10);
% % B=gh;
% % b=boundaries(B,4,'cw');
% % b=b{1};
% % [M,N]=size(B);
% % xmin=min(b(:,1));
% % ymin=min(b(:,2));
% % bim=bound2im(b,M,N,xmin,ymin);
% 
% % figure(2)
% subplot(2,3,1)
% imshow(histed)
% title('원본 히스토그램 평활화')
% 
% subplot(2,3,2)
% imshow(histed2)
% title('콘트라스트-스트레칭 변환, 히스토그램 평활화')
% 
% subplot(2,3,3)
% imshow(gh1)
% title('히스토그램 평활화+가우시안 필터')
% 
% subplot(2,3,4)
% imshow(L)
% title('그레이 문턱치값 0 or 1 + 각 도형마다 라벨링 되어있음')
% 
% subplot(2,3,5)
% imhist(histed)
% title('original histogram')
% 
% subplot(2,3,6)
% imhist(histed2)
% title('equaled histogram')
% 
% %히스토그램
% figure(5)
% subplot(2,2,1)
% imshow(histed)
% 
% subplot(2,2,2)
% imhist(histed)
% 
% subplot(2,2,3)
% imshow(histed2)
% 
% subplot(2,2,4)
% imhist(histed2)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%