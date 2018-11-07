function imagesctx(mat, xlabels, ylabels, xrot)
[m, n] = size(mat);
imagesc(mat);            %# Create a colored plot of the matrix values
colormap(flipud(gray));  %# Change the colormap to gray (so higher values are
                         %#   black and lower values are white)

textStrings = num2str(mat(:),'%0.2f');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:n, 1:m);   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:), textStrings(:),...      %# Plot the strings
                 'HorizontalAlignment','center');
midValue = mean(get(gca, 'CLim'));  %# Get the middle value of the color range
textColors = repmat(mat(:) > midValue,1,3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors
set(gca,'XTick', 1:n, 'YTick', 1:m, 'TickLength',[0 0]);
if nargin >= 3 && ~isempty(ylabels)
    set(gca,'YTickLabel',ylabels);
end
if nargin >= 2 && ~isempty(xlabels)
    set(gca,'XTickLabel',xlabels);
    if nargin >= 4 && ~isempty(xrot)
        rotateticklabel(gca, xrot);
    end
end

function th=rotateticklabel(h,rot)
%ROTATETICKLABEL rotates tick labels
%   TH=ROTATETICKLABEL(H,ROT) is the calling form where H is a handle to
%   the axis that contains the XTickLabels that are to be rotated. ROT is
%   an optional parameter that specifies the angle of rotation. The default
%   angle is 90. TH is a handle to the text objects created. For long
%   strings such as those produced by datetick, you may have to adjust the
%   position of the axes so the labels don't get cut off.
%
%   Of course, GCA can be substituted for H if desired.
%
%   TH=ROTATETICKLABEL([],[],'demo') shows a demo figure.
%
%   Known deficiencies: if tick labels are raised to a power, the power
%   will be lost after rotation.
%
%   See also datetick.

%   Written Oct 14, 2005 by Andy Bliss
%   Copyright 2005 by Andy Bliss

%set the default rotation if user doesn't specify
if nargin==1
    rot=90;
end
%make sure the rotation is in the range 0:360 (brute force method)
while rot>360
    rot=rot-360;
end
while rot<0
    rot=rot+360;
end
% reduce hight to make room for the rotated x labels
pos = get(h,'Position');
% set(h,'Position',[pos(1)*2.5 pos(2)*2.5 pos(3)-pos(1) pos(4)-pos(2)]);%0.3, .4, pos(3) .55])
set(h,'Position',[pos(1) pos(1) pos(3) pos(4)-pos(1)]);%0.3, .4, pos(3) .55])
%get current tick labels
a=get(h,'XTickLabel');
%erase current tick labels from figure
set(h,'XTickLabel',[]);
%get tick label positions
b=get(h,'XTick');
c=get(h,'YTick');
%make new tick labels
if rot<180
    th=text(b,repmat(c(end)+.7*(c(end)-c(end-1)),length(b),1),a,'HorizontalAlignment','right','rotation',rot);
else
    th=text(b,repmat(c(1)-.1*(c(2)-c(1)),length(b),1),a,'HorizontalAlignment','left','rotation',rot);
end

