function h = circle2(x,y,r)
th = 0:pi/50:2*pi;
xunit = r*cos(th) + x;
yunit = r*sin(th) + y;
h = plot(xunit, yunit,'r');
set(h,'LineWidth',3);
end