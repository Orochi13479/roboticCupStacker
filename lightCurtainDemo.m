clear all;
clc;
clf;
hold on;
axis equal;

% Force figure limits
zlim([0, 2]);
xlim([-2, 2]); % xlim([-4.2, 4.2]); <-- SHOULD PROBS MAKE SMALLER
ylim([-2, 2]); % ylim([-2.5, 2.5]); <-- SHOULD PROBS MAKE SMALLER

% Robot Initialisations
% Initialise and Plot the UR3e object
UR3eRobot = UR3e;
UR3e = UR3eRobot.model;

% Initialise and Plot the WidowX250 object
X250Robot = WidowX250;
WidowX250 = X250Robot.model;

% Initialise and Plot the WidowX250 Gripper object
X250GripperL = WidowX250Gripper;
WidowX250GripperL = X250GripperL.model;
X250GripperR = WidowX250Gripper;
WidowX250GripperR = X250GripperR.model;

%Initialise and Plot the UR3e Gripper object
URGripperL = UR3eGripper;
UR3eGripperL = URGripperL.model;
URGripperR = UR3eGripper;
UR3eGripperR = URGripperR.model;

% Reduce lag
UR3e.delay = 0;
WidowX250.delay = 0;
WidowX250GripperL.delay = 0;
WidowX250GripperR.delay = 0;
UR3eGripperL.delay = 0;
UR3eGripperR.delay = 0;

% Manipulate the WidowX250 Base If custom position e.g. On top of a table
% Gather default rotation and translation matrices
[armRotationMatrix1, armTranslationVector1] = tr2rt(WidowX250.base);
[armRotationMatrix2, armTranslationVector2] = tr2rt(UR3e.base);

% Translate along each axis
% translationVector1 = [-0.3, 0, 0.5];
% translationVector2 = [0.3, 0, 0.5];

translationVector1 = [-0.3, -0.6, 0.5];
translationVector2 = [0.3, -0.6, 0.5];

% Specify the rotation angle in radians
angle = pi;

% Create a rotation matrix for the Z-axis rotation
Rz = [cos(angle), -sin(angle), 0; ...
    sin(angle), cos(angle), 0; ...
    0, 0, 1];

WidowX250.base = rt2tr(armRotationMatrix1, translationVector1);
UR3e.base = rt2tr(armRotationMatrix2, translationVector2);

% Set Base of WidowX250 Gripper to End effector
WidowX250GripperL.base = WidowX250.fkine(WidowX250.getpos()).T * trotx(-pi/2) * troty(pi) * transl(0, 0.023, 0);
WidowX250GripperR.base = WidowX250.fkine(WidowX250.getpos()).T * trotx(-pi/2) * transl(0, 0.023, 0);

% Set Base of UR3e Gripper to End effector
UR3eGripperL.base = UR3e.fkine(UR3e.getpos).T*trotx(pi/2);
UR3eGripperR.base = UR3e.fkine(UR3e.getpos).T*trotz(pi)*trotx(pi/2);

% Assume starting position
UR3e.animate(UR3e.getpos());
WidowX250.animate(WidowX250.getpos());
WidowX250GripperL.animate([0, 0.03]);
WidowX250GripperR.animate([0, 0.03]);
UR3eGripperL.animate([0, 0, 0]);
UR3eGripperR.animate([0, 0, 0]);

q1 = [-pi / 4, 0, 0];
q2 = [pi / 4, 0, 0];
steps = 2;
while ~isempty(find(1 < abs(diff(rad2deg(jtraj(q1, q2, steps)))),1))
    steps = steps + 1;
end
qMatrix = jtraj(q1, q2, steps);

%% Environment
folderName = 'data';

% Environment - Table dimensions
TableDimensions = [2.1, 1.4, 0.5]; %[Length, Width, Height]
wheeledTableDimensions = [0.75, 1.2, 0.52]; %[Length, Width, Height]
tableHeight = TableDimensions(3);

% Concrete floor
surf([-4.3, -4.3; 4.3, 4.3] ...
    , [-2.2, 2.2; -2.2, 2.2] ...
    , [0.01, 0.01; 0.01, 0.01] ...
    , 'CData', imread(fullfile(folderName, 'woodenFloor.jpg')), 'FaceColor', 'texturemap');

% Place objects in environment
PlaceObject(fullfile(folderName, 'rubbishBin2.ply'), [-0.4, -1, tableHeight]);
PlaceObject(fullfile(folderName, 'rubbishBin2.ply'), [0.2, -1, tableHeight]);
PlaceObject(fullfile(folderName, 'brownTable.ply'), [0, 0, 0]);
PlaceObject(fullfile(folderName, 'warningSign.ply'), [1.5, -1.5, 0]);
% PlaceObject(fullfile(folderName, 'assembledFence.ply'), [0.25, 0.7, -0.97]);
PlaceObject(fullfile(folderName, 'wheeledTable.ply'), [-0.8, -0.75, 0]);
PlaceObject(fullfile(folderName, 'tableChair.ply'), [-1.6, -0.25, 0]);
PlaceObject(fullfile(folderName, 'wheelieBin.ply'), [1.2, 2, 0]);
PlaceObject(fullfile(folderName, 'cabinet.ply'), [0, 2, 0]);
PlaceObject(fullfile(folderName, 'cabinet.ply'), [-1, 2, 0]);

% Light Curtain Placements
PlaceObject(fullfile(folderName, 'lightCurtain.ply'), [1.2, -1.5, 0.85]);
PlaceObject(fullfile(folderName, 'lightCurtain.ply'), [1.2, 1, 0.85]);
PlaceObject(fullfile(folderName, 'lightCurtain.ply'), [-1.2, -1.5, 0.85]);
PlaceObject(fullfile(folderName, 'lightCurtain.ply'), [-1.2, 1, 0.85]);

[y1,z1] = meshgrid(-1.5:0.01:1, 0.1:0.01:1.5);  %setting location of meshgrid
x1 = zeros(size(y1)) - 1.2;
lightCurtain1 = surf(x1,y1,z1,'FaceAlpha',0.1,'EdgeColor','none');
hold on;

% [y2,z2] = meshgrid(1.5:0.01:-1, 0.1:0.01:1.5);  %setting location of meshgrid
% x2 = zeros(size(y2)) + 0.2;
% lightCurtain2 = surf(x2,y2,z2,'FaceAlpha',0.1,'EdgeColor','none');
% hold on;



% PlaceObject('emergencyStopButton.ply', [0.96, 0.6, TableDimensions(3)]);

%% Place Movable objects
% Create Cups and Place Randomly
cupHeight = 0.1;

% 14 Cups to Start with
% X250 has 7 Cups

initCupArrayX250 = [; ...
    -0.1, -0.25, tableHeight; ...
    -0.3, -0.3, tableHeight; ...
    -0.45, -0.3, tableHeight; ...
    -0.45, -0.3, tableHeight + cupHeight; ...
    -0.55, -0.4, tableHeight; ...
    -0.6, -0.5, tableHeight; ...
    -0.6, -0.5, tableHeight + cupHeight; ...
    ];

for i = 1:length(initCupArrayX250)
    % Place the Cup using PlaceObject
    self.cupX250(i) = PlaceObject(fullfile(folderName, 'sodaCan.ply'), [initCupArrayX250(i, 1), initCupArrayX250(i, 2), initCupArrayX250(i, 3)]);
end

% UR3e has 7 Cups
initCupArrayUR3 = [; ...
    0, -0.4, tableHeight; ...
    0.1, -0.25, tableHeight; ...
    0.2, -0.3, tableHeight; ...
    0.3, -0.2, tableHeight; ...
    0.5, -0.5, tableHeight; ...
    0.5, -0.3, tableHeight; ...
    0.6, -0.5, tableHeight; ...
    ];

for i = 1:length(initCupArrayUR3)
    % Place the Cup using PlaceObject
    self.cupUR3(i) = PlaceObject(fullfile(folderName, 'plasticCup.ply'), [initCupArrayUR3(i, 1), initCupArrayUR3(i, 2), initCupArrayUR3(i, 3)]);
end

disp('Setup is complete');

%%  Light Curtain Demo

[f,v,data] = plyread(fullfile('data', 'sodaCan.ply'), 'tri');
canVertices = v;

Initial = [-1.5,0,0.5];
Final = [1.2, 0, 0.5];

steps = 30;

xCan = -1.5;
canHandles = [];

for j = 1:steps
    % Delete previously created cans
    if ~isempty(canHandles)
        delete(canHandles);
        canHandles = [];
    end

    % Create a new soda can
    canHandle = PlaceObject(fullfile('data', 'sodaCan.ply'), [xCan, 0, 0.6]);
    canHandles = [canHandles, canHandle]; % Store the handle

    pause(0.2);

    xCan = xCan + 0.01;
    canVertices(:, 1) = canVertices(:, 1) + xCan;
    drawnow;

    if xCan >= -1.2
        fprintf("Light Curtain has been activated\n");
        lightCurtain1 = surf(x1, y1, z1, 'FaceAlpha', 0.1, 'FaceColor', 'red');
        set(gcf, 'color', 'r');
    end
end





