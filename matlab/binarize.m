function [Mask L b degree stat MeanRadius MeanArea]= binarize(image)
global Column;
global Row;
global Edge;

% histed=intrans(image,'stretch',mean2(im2double(image)),0.9);
% histed1=histed;
% histed=histeq(histed);
histed=histeq(image);


h=fspecial('gaussian',70,15);
gh=imfilter(histed,h,'replicate');
gh=im2bw(gh,Edge*graythresh(gh));
L=bwlabel(gh,4);

%오브젝트 개수 세기
num=max(max(L)); %오브젝트 개수
% ncol=input('Enter the number of colomuns : ');   %가로개수
% nraw=input('Enter the number of raws : ');   %세로개수
% n=ncol*nraw;    %입력값 총 개수
n=Column*Row;
% fprintf('%f개로 걸러내겠습니다! : %f\n',n)


%라벨링해서 n개보다 많으면 n개가 될때까지 가장 작은 면적을 가진 라벨링 없앰
for i=1:num
    noe(i)= sum(sum(L==i));     %Number of dots(area)
end
% noesort=sort(noe);
% noeavg=sum(noe)/num;
% 
% for i=1:num
%     if noe(i) < noeavg/4
%         for j=1:size(L,1)
%             for k=1:size(L,2)
%                 if L(j,k) == i
%                     L(j,k) = 0;
%                 end
%             end
%         end
%     end
% end
noeavg=sum(noe)/num;

for i=1:num
    if noe(i) < noeavg/4
        for j=1:size(L,1)
            for k=1:size(L,2)
                if L(j,k) == i
                    L(j,k) = 0;
                end
            end
        end
    end
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
% 
% for k = 1:max(max(L))
%     if sum(sum(L==k)) > 3*MeanArea
%         for i=1:size(L,1)
%             for j=1:size(L,2)
%                 if L(i,j) == k
%                     L(i,j) =0;
%                 end
%             end
%         end
%     end
% end
% 
% L = bwlabel(L);


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

%%%%%%%%%%%%%%%
for k=1:numel(stat)
    Ypos(k)=stat(k).Centroid(2);
    Xpos(k)=stat(k).Centroid(1);
end
Ymax=max(Ypos);
Ymin=min(Ypos);
interval = (Ymax-Ymin)/Row;
Rcount=zeros(Row,1);
for k=1:numel(stat)
    for i=1:Row
        if (stat(k).Centroid(2)>=Ymax+(i-1)*interval-interval/2)&(stat(k).Centroid(2)<=Ymax+(i)*interval-interval/2)
            Rcount(i)=Rcount(i)+1;
            Ry(i,Rcount(i))=stat(k).Centroid(2);
            Rx(i,Rcount(i))=stat(k).Centroid(1);
        end
    end
end
TheRow=find(Rcount==max(Rcount));

xavg=sum(Rx(TheRow,:))/Rcount(TheRow);
bnom=0;
bdenom=0;
for k=1:Rcount(TheRow)
    bnom=bnom+Ry(TheRow,k)*(Rx(TheRow,k)-xavg);
    bdenom=bdenom+Rx(TheRow,k)*(Rx(TheRow,k)-xavg);
end


%%%%%%%%%%%%%%%

b=bnom/bdenom;
degree=atand(b);
Mask=L;