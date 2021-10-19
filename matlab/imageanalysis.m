function imageanalysis(motherfolder,representation)
%% 기본원리
% 1. 상위 폴더 내의 하위 폴더를 검색하여 nameFolds{i} 에 저장
% 2. 각 하위 폴더내의 파일을 순서대로 읽어서, filename(i) 에 저장
% 3. 가장잘나온 사진(대표)상의 중심(원이라 가정, 8개)사이의 거리, 평균 반지름 등의 정보를 입력 
% 4. 대표 사진의 기울기를 수평으로 맞춘 뒤, 테두리를 잘라냄.(마스크 생성)
% 5. 분석하고자 하는 이미지의 기울기를 분석하여 마스크를 해당 기울기에 맞게 회전.
% 6. Template matching 을 이용하여 마스크와 이미지가 가장 장 매칭이 되는 지점을 찾아 마스킹을 한후 평균 밝기 측정
% 7. 왼쪽 아래서부터 오른쪽 위까지 순서대로 1~8까지 평균 Brightness 를 기록.
% 8. 엑셀파일로 출력

%% 사용법
% Column 과 Row 와 Magnitude 값을 입력한다.
% 아래와 같이 폴더명과 대표이미지 경로를 입력한다
% imageanalysis('C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\','C:\Users\moon\Dropbox\2014 summer research\2014.05.26 Tn5 FAB 2nd 100um reactor\Left 1-4\Acquired-6.tif')
% 상위 폴더에 Brightness.xls 엑셀파일 생성.
% 자세한 작동원리는 analysis.m 파일 참조.
% Undefined function 'imageanalysis' for input arguments of type... 에러가 뜰시
% 본파일에서 F5 한번 실행후 change folder 후, 커맨드에 다시 입력.

global MeanArea;
global MeanRadius;
global Magnitude;


d = dir(motherfolder);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];
excel = strcat(motherfolder,'brightness.xls');

%% 4. 엑셀파일로 출력
for i=1:length(nameFolds)
    [Brightsum Filename]=analysis(strcat(motherfolder, nameFolds{i},'\'),representation);
    xlswrite(excel,{nameFolds{i} '1' '2' '3' '4' '5' '6' '7' '8'},nameFolds{i});
    xlswrite(excel,Brightsum,nameFolds{i},'A2');
    xlswrite(excel,Filename',nameFolds{i},'A2');
    fprintf('%d 번째 출력 끝. \n',i);
end
xlswrite(excel,...
    {'position' '2' '4' '6' '8';'' '1' '3' '5' '7';'왼쪽 아래서부터 1,2,3...오른쪽 위까지' '' '' '' '';...
    'MeanRadius' num2str(MeanRadius) '' '' '';'MeanArea' num2str(MeanArea) '' '' '';'Magnitude' num2str(Magnitude) '' '' ''},'howtosee');

fprintf('엑셀 파일 출력 끝. \n');