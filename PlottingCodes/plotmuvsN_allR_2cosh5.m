load Output_2cosh5_R3.mat
%Ne mu muAtom
N3=Ne;
mu3=mu;

load Output_2cosh5_R15.mat
%Ne mu muAtom
Ninf=Ne;
muinf=mu;

load Output_2cosh5_R5.mat
%Ne mu muAtom
N5=Ne;
mu5=mu;


% load L_25L_3.66V0_5R_40e.mat
% 
% 
% load L_25L_3.66V0_5R_39e.mat



%% plot settings

load colors.mat

width = 20;
height = 12;

left = .15;
right = .1;
bottom = .22;
top = .05;
midspacehor = .01;
midspacevert = .07;

% in percentage of total width
plotwidth = (1-left-right);
plotheight = (1-bottom-top);

% Create figure
% Example how to adjust your figure properties for
% publication needs
figure1 = figure;
% Select the default font and font size
% Note: Matlab does internally round the font size
% to decimal pt values
set(figure1, 'DefaultTextFontSize', 24); % [pt]
set(figure1, 'DefaultAxesFontSize', 24); % [pt]
set(figure1, 'DefaultAxesFontName', 'Times');
set(figure1, 'DefaultTextFontName', 'Times');
% Select the preferred unit like inches, centimeters,
% or pixels
set(figure1, 'Units', 'centimeters');
pos = get(figure1, 'Position');
pos(3) = width; % Select the width of the figure in [cm]
pos(4) = height; % Select the height of the figure in [cm]
set(figure1, 'Position', pos);
% set(figure1, 'Colormap',c);
% set(figure1,  'Colormap',[0 0 0.5625;0 0 0.591666638851166;0 0 0.620833337306976;0 0 0.649999976158142;0 0 0.679166674613953;0 0 0.708333313465118;0 0 0.737500011920929;0 0 0.766666650772095;0 0 0.795833349227905;0 0 0.824999988079071;0 0 0.854166686534882;0 0 0.883333325386047;0 0 0.912500023841858;0 0 0.941666662693024;0 0 0.970833361148834;0 0 1;0 0.0769230797886848 1;0 0.15384615957737 1;0 0.230769231915474 1;0 0.307692319154739 1;0 0.384615391492844 1;0 0.461538463830948 1;0 0.538461565971375 1;0 0.615384638309479 1;0 0.692307710647583 1;0 0.769230782985687 1;0 0.846153855323792 1;0 0.923076927661896 1;0 1 1;0.16666667163372 1 0.833333313465118;0.333333343267441 1 0.666666686534882;0.5 1 0.5;0.666666686534882 1 0.333333343267441;0.833333313465118 1 0.16666667163372;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.961538434028625 0 0;0.923076927661896 0 0;0.884615361690521 0 0;0.846153855323792 0 0;0.807692289352417 0 0;0.769230782985687 0 0;0.730769217014313 0 0;0.692307710647583 0 0;0.653846144676208 0 0;0.615384638309479 0 0;0.576923072338104 0 0;0.538461565971375 0 0;0.5 0 0]);
set(figure1, 'Renderer', 'painters');
% From SVG 1.1. Specification:
% "1pt" equals "1.25px"
% "1pc" equals "15px"
% "1mm" would be "3.543307px"
% "1cm" equals "35.43307px"
% "1in" equals "90px"


%% Create axes top plot
axes2 = axes('Parent',figure1,...
    'Position',[left bottom plotwidth plotheight],...
    'MinorGridLineStyle','none',...
    'LineWidth',3,...
    'Layer','top',...
    'GridLineStyle','none');
%     'Position',[left+midspacehor+plotwidth bottom plotwidth
%     plotheight],...
box(axes2,'on');
hold(axes2,'all');





plot(mu5,N5,'LineWidth',3,'Color','r');
plot(mu3,N3,'LineWidth',3,'Color','b','LineStyle',':');
plot(muinf,Ninf,'LineWidth',2,'Color','k','LineStyle','-.');


xlim([-1.8,-0.1])
ylim([0,3.1])


% Create xlabel
xlabel('\it \mu \rm','FontSize',30,'FontName','Times');

% Create ylabel
ylabel('\it N_{atom} \rm','FontSize',30,'FontName','Times');




set(figure1,'PaperPositionMode','auto','PaperUnits','centimeters','PaperSize',[width height]);
print('muvsN_2cosh5_Rall','-dpdf')
print('muvsN_2cosh5_Rall','-depsc')