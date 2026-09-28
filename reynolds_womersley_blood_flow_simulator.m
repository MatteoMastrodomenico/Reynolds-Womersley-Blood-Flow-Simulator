function reynolds_womersley_blood_flow_simulator
% REYNOLDS_WOMERSLEY_BLOOD_FLOW_SIMULATOR
% Interactive MATLAB visualization of flow inside a straight circular pipe.
% Compared with v3, this version makes the flow regime recognizable FROM
% THE IMAGE itself:
%   - Laminar: straight parallel streamlines.
%   - Transitional: mildly wavy streamlines.
%   - Turbulent-like: visible swirling/helical vortical streaklines.
%
% Educational model:
%   Re    = rho*U*D/mu
%   alpha = (D/2)*sqrt(omega*rho/mu)
%
% Physics note: this is a high-quality educational visualization, not a
% full CFD Navier-Stokes solver.

%% --------------------------- INITIAL STATE ----------------------------
S.rho   = 1060;          % kg/m^3
S.mu    = 3.5e-3;        % Pa*s
S.D     = 20e-3;         % m
S.U     = 0.35;          % m/s
S.f     = 1.20;          % Hz
S.pulse = true;
S.oscAmp = 0.45;         % oscillatory mean velocity / U
S.paused = false;
S.closed = false;
S.t = 0;
S.visualTimeScale = 0.24;
S.lastClock = tic;
S.Re = reynolds(S.rho,S.U,S.D,S.mu);
S.alpha = womersley(S.rho,S.mu,S.D,S.f);

LoverD = 12;
R = 0.5;                 % dimensionless radius in the 3-D view
nShells = 15;
Nlines = 18;
xLine = linspace(0,LoverD,240);

%% ------------------------------ WINDOW -------------------------------
fig = uifigure('Name','Reynolds-Womersley Blood Flow Simulator', ...
    'Color',[0.95 0.96 0.98], ...
    'Position',[30 30 1510 870], ...
    'CloseRequestFcn',@closeApp);

root = uigridlayout(fig,[1 2]);
root.ColumnWidth = {370,'1x'};
root.Padding = [10 10 10 10];
root.ColumnSpacing = 10;
root.BackgroundColor = [0.95 0.96 0.98];

%% ---------------------------- CONTROLS -------------------------------
panel = uipanel(root,'Title','FLOW CONTROLS', ...
    'FontWeight','bold','FontSize',15, ...
    'ForegroundColor',[0.03 0.05 0.09], ...
    'BackgroundColor',[0.985 0.988 0.995]);
panel.Layout.Row = 1;
panel.Layout.Column = 1;

cg = uigridlayout(panel,[24 1]);
cg.RowHeight = {28,46,28,46,28,46,28,46,28,46,28,46,28,46,28,34,36,36,36,42,120,26,26,'1x'};
cg.Padding = [12 10 12 10];
cg.RowSpacing = 3;
cg.BackgroundColor = [0.985 0.988 0.995];

labelColor = [0.02 0.04 0.08];
subtleColor = [0.24 0.29 0.36];

makeLabel('Reynolds number  Re');
sRe = uislider(cg,'Limits',[10 20000],'Value',S.Re, ...
    'MajorTicks',[10 2300 4000 10000 20000]);
sRe.ValueChangingFcn = @(~,e) setRe(e.Value);
sRe.ValueChangedFcn  = @(s,~) setRe(s.Value);

makeLabel('Womersley number  alpha');
sAlpha = uislider(cg,'Limits',[0.2 40],'Value',S.alpha, ...
    'MajorTicks',[0.2 1 5 10 20 30 40]);
sAlpha.ValueChangingFcn = @(~,e) setAlpha(e.Value);
sAlpha.ValueChangedFcn  = @(s,~) setAlpha(s.Value);

makeLabel('Mean velocity  U  [m/s]');
sU = uislider(cg,'Limits',[0.01 2.0],'Value',S.U, ...
    'MajorTicks',[0.01 0.25 0.5 1 1.5 2]);
sU.ValueChangingFcn = @(~,e) setU(e.Value);
sU.ValueChangedFcn  = @(s,~) setU(s.Value);

makeLabel('Dynamic viscosity  mu  [mPa s]');
sMu = uislider(cg,'Limits',[0.5 20],'Value',S.mu*1e3, ...
    'MajorTicks',[0.5 1 3.5 5 10 15 20]);
sMu.ValueChangingFcn = @(~,e) setMu(e.Value);
sMu.ValueChangedFcn  = @(s,~) setMu(s.Value);

makeLabel('Density  rho  [kg/m^3]');
sRho = uislider(cg,'Limits',[600 1400],'Value',S.rho, ...
    'MajorTicks',[600 800 1000 1060 1200 1400]);
sRho.ValueChangingFcn = @(~,e) setRho(e.Value);
sRho.ValueChangedFcn  = @(s,~) setRho(s.Value);

makeLabel('Hydraulic diameter  D_h  [mm]');
sD = uislider(cg,'Limits',[2 50],'Value',S.D*1e3, ...
    'MajorTicks',[2 5 10 20 30 40 50]);
sD.ValueChangingFcn = @(~,e) setD(e.Value);
sD.ValueChangedFcn  = @(s,~) setD(s.Value);

makeLabel('Pulsation amplitude  [% of mean U]');
sAmp = uislider(cg,'Limits',[0 90],'Value',100*S.oscAmp, ...
    'MajorTicks',[0 25 45 60 75 90]);
sAmp.ValueChangingFcn = @(~,e) setAmp(e.Value);
sAmp.ValueChangedFcn  = @(s,~) setAmp(s.Value);

flowRow = uigridlayout(cg,[1 3]);
flowRow.ColumnWidth = {'1x',85,85};
flowRow.Padding = [0 0 0 0];
flowRow.BackgroundColor = [0.985 0.988 0.995];
uilabel(flowRow,'Text','Flow type','FontWeight','bold','FontColor',labelColor);
switchPulse = uiswitch(flowRow,'slider','Items',{'Steady','Pulsatile'},'Value','Pulsatile');
switchPulse.Layout.Column = [2 3];
switchPulse.ValueChangedFcn = @(s,~) setPulse(strcmp(s.Value,'Pulsatile'));

bPause = uibutton(cg,'push','Text','Pause animation', ...
    'FontWeight','bold','ButtonPushedFcn',@togglePause);
bReset = uibutton(cg,'push','Text','Reset animation phase', ...
    'ButtonPushedFcn',@resetAnimation);
bView = uibutton(cg,'push','Text','Reset 3-D view', ...
    'ButtonPushedFcn',@resetView);

navRow = uigridlayout(cg,[1 4]);
navRow.ColumnWidth = {'1x','1x','1x','1x'};
navRow.Padding = [0 0 0 0];
navRow.ColumnSpacing = 5;
navRow.BackgroundColor = [0.985 0.988 0.995];
bRotate = uibutton(navRow,'state','Text','Rotate 3-D','Value',true, ...
    'ValueChangedFcn',@(b,~) setNavMode('rotate',b.Value));
bPan = uibutton(navRow,'state','Text','Pan', ...
    'ValueChangedFcn',@(b,~) setNavMode('pan',b.Value));
bZoomIn = uibutton(navRow,'push','Text','Zoom +','ButtonPushedFcn',@zoomInView);
bZoomOut = uibutton(navRow,'push','Text','Zoom -','ButtonPushedFcn',@zoomOutView);

info = uitextarea(cg,'Editable','off', ...
    'FontName','Consolas','FontSize',12, ...
    'BackgroundColor',[0.08 0.10 0.13], ...
    'FontColor',[0.97 0.98 1.00], ...
    'Value',{'Initializing...'});

uilabel(cg,'Text','Laminar = straight lines. Turbulent-like = swirling vortices.', ...
    'FontAngle','italic','FontSize',10,'FontColor',subtleColor);
uilabel(cg,'Text','Editing Re changes U. Editing alpha changes frequency.', ...
    'FontAngle','italic','FontSize',10,'FontColor',subtleColor);

%% ------------------------- VISUALIZATION AREA ------------------------
right = uigridlayout(root,[3 1]);
right.RowHeight = {42,'3x','1x'};
right.RowSpacing = 8;
right.Padding = [0 0 0 0];
right.BackgroundColor = [0.95 0.96 0.98];
right.Layout.Row = 1;
right.Layout.Column = 2;

regimeBanner = uipanel(right,'BackgroundColor',[0.93 0.95 0.98], ...
    'BorderType','line','HighlightColor',[0.68 0.72 0.80]);
regimeBanner.Layout.Row = 1;
regimeGrid = uigridlayout(regimeBanner,[1 2]);
regimeGrid.ColumnWidth = {'1x','1x'};
regimeGrid.Padding = [12 3 12 3];
regimeGrid.BackgroundColor = [0.93 0.95 0.98];
regimeLabel = uilabel(regimeGrid,'Text','FLOW REGIME', ...
    'FontWeight','bold','FontSize',14,'FontColor',[0.04 0.07 0.12]);
navHint = uilabel(regimeGrid,'Text','Drag to rotate | Toolbar: pan / zoom / restore', ...
    'HorizontalAlignment','right','FontSize',11,'FontColor',[0.25 0.30 0.38]);

ax3 = uiaxes(right);
ax3.Layout.Row = 2;
setup3DAxes();
setupNavigation();

axP = uiaxes(right);
axP.Layout.Row = 3;
axP.Color = [0.985 0.99 1.0];
axP.XColor = [0.08 0.10 0.14];
axP.YColor = [0.08 0.10 0.14];
axP.GridColor = [0.55 0.60 0.68];
axP.GridAlpha = 0.35;
axP.Box = 'on';
grid(axP,'on');
hold(axP,'on');
xlabel(axP,'Axial velocity u(r,t) [m/s]');
ylabel(axP,'r / R');
title(axP,'INSTANTANEOUS VELOCITY PROFILE','Color',[0.04 0.07 0.12],'FontWeight','bold');
ylim(axP,[-1 1]);

rDisplay = linspace(-1,1,241);
hProfile = plot(axP,zeros(size(rDisplay)),rDisplay,'LineWidth',2.7,'Color',[0.00 0.38 0.85]);
hZero = xline(axP,0,':','Color',[0.35 0.38 0.45]);
hMean = xline(axP,S.U,'--','Color',[0.86 0.35 0.05],'LineWidth',1.5);
legend(axP,[hProfile hZero hMean],{'u(r,t)','u = 0','mean U'}, ...
    'Location','eastoutside','TextColor',[0.08 0.10 0.14],'Color',[1 1 1]);

%% --------------------------- STATIC GEOMETRY -------------------------
[xFloor,yFloor] = meshgrid(linspace(0,LoverD,18), linspace(-1.0,1.0,12));
zFloor = -0.72*ones(size(xFloor));
surf(ax3,xFloor,yFloor,zFloor, ...
    'FaceColor',[0.93 0.95 0.985], ...
    'FaceAlpha',0.55, ...
    'EdgeColor',[0.60 0.67 0.76], ...
    'EdgeAlpha',0.45, ...
    'LineWidth',0.55);

thWall = linspace(0,2*pi,100);
xxWall = linspace(0,LoverD,90);
[THw,XW] = meshgrid(thWall,xxWall);
YW = R*cos(THw);
ZW = R*sin(THw);
wall = surf(ax3,XW,YW,ZW, ...
    'FaceColor',[0.64 0.79 0.97], ...
    'FaceAlpha',0.15, ...
    'EdgeColor',[0.26 0.45 0.64], ...
    'EdgeAlpha',0.15, ...
    'LineWidth',0.35);

plot3(ax3,zeros(size(thWall)),R*cos(thWall),R*sin(thWall), ...
    'Color',[0.07 0.26 0.46],'LineWidth',2.2);
plot3(ax3,LoverD*ones(size(thWall)),R*cos(thWall),R*sin(thWall), ...
    'Color',[0.07 0.26 0.46],'LineWidth',2.2);
for ang = linspace(0,2*pi,10)
    plot3(ax3,[0 LoverD],R*cos(ang)*[1 1],R*sin(ang)*[1 1], ...
        'Color',[0.40 0.56 0.72],'LineWidth',0.6);
end
plot3(ax3,[0 LoverD],[0 0],[0 0],'--','Color',[0.18 0.22 0.30],'LineWidth',1.1);

%% -------------------- CONTINUOUS FLUID REPRESENTATION ----------------
xx = linspace(0,LoverD,110);
th = linspace(0,2*pi,90);
[TH,XX] = meshgrid(th,xx);

rShell = linspace(0.06,R*0.97,nShells);
hShell = gobjects(nShells,1);
for k = 1:nShells
    rk = rShell(k);
    Y = rk*cos(TH);
    Z = rk*sin(TH);
    C = zeros(size(Y));
    alphaShell = 0.045 + 0.055*(1 - rk/R) + 0.012*cos((k-1)/(nShells-1)*pi);
    hShell(k) = surf(ax3,XX,Y,Z,C, ...
        'EdgeColor','none', ...
        'FaceAlpha',max(0.035,min(alphaShell,0.16)), ...
        'SpecularStrength',0.16, ...
        'DiffuseStrength',0.86, ...
        'AmbientStrength',0.55);
end

rCore = 0.12;
Yc = rCore*cos(TH);
Zc = rCore*sin(TH);
Ccore = zeros(size(Yc));
hCore = surf(ax3,XX,Yc,Zc,Ccore, ...
    'EdgeColor','none', ...
    'FaceAlpha',0.20, ...
    'SpecularStrength',0.25, ...
    'DiffuseStrength',0.95);

rq = linspace(0,R*0.985,65);
tq = linspace(0,2*pi,120);
[RQ,TQ] = meshgrid(rq,tq);
YQ = RQ.*cos(TQ);
ZQ = RQ.*sin(TQ);
XQ0 = zeros(size(RQ));
XQ1 = LoverD*ones(size(RQ));
CQ = zeros(size(RQ));
hInlet = surf(ax3,XQ0,YQ,ZQ,CQ,'EdgeColor','none','FaceAlpha',0.92);
hOutlet = surf(ax3,XQ1,YQ,ZQ,CQ,'EdgeColor','none','FaceAlpha',0.65);

[xSlice,ySlice] = meshgrid(linspace(0,LoverD,120), linspace(-R*0.985,R*0.985,120));
zSlice = zeros(size(xSlice));
rnSlice = min(abs(ySlice)/R,1);
maskSlice = abs(ySlice) <= R;
Cslice = nan(size(xSlice));
Cslice(maskSlice) = 0;
hSlice = surf(ax3,xSlice,ySlice,zSlice,Cslice, ...
    'EdgeColor','none','FaceAlpha',0.35);

%% --------------------- REGIME-IDENTIFYING STREAMLINES ---------------
lineR = [0.10 0.10 0.10 0.10 0.22 0.22 0.22 0.22 0.22 0.22 0.34 0.34 0.34 0.34 0.34 0.44 0.44 0.44];
lineA = linspace(0,2*pi,Nlines+1); lineA(end) = [];
lineBaseColor = turbo(Nlines);
hLines = gobjects(Nlines,1);
for k = 1:Nlines
    y0 = lineR(k)*cos(lineA(k));
    z0 = lineR(k)*sin(lineA(k));
    hLines(k) = plot3(ax3,xLine,y0*ones(size(xLine)),z0*ones(size(xLine)), ...
        'LineWidth',1.6,'Color',lineBaseColor(k,:));
end


colormap(ax3,turbo(256));
cb = colorbar(ax3);
cb.Color = [0.07 0.10 0.15];
cb.Label.String = 'Axial velocity [m/s]';
cb.Label.Color = [0.07 0.10 0.15];

updateAllUI();
updateVisuals();
drawnow;

%% ------------------------------- TIMER -------------------------------
animTimer = timer( ...
    'ExecutionMode','fixedSpacing', ...
    'Period',0.040, ...
    'BusyMode','drop', ...
    'TimerFcn',@onTimer, ...
    'ErrorFcn',@onTimerError);
S.lastClock = tic;
start(animTimer);

%% =========================== NESTED FUNCTIONS ========================
    function makeLabel(txt)
        uilabel(cg,'Text',txt,'FontWeight','bold','FontColor',labelColor);
    end

    function setup3DAxes()
        ax3.Color = [0.985 0.989 0.997];
        ax3.XColor = [0.08 0.11 0.16];
        ax3.YColor = [0.08 0.11 0.16];
        ax3.ZColor = [0.08 0.11 0.16];
        ax3.GridColor = [0.55 0.62 0.72];
        ax3.GridAlpha = 0.38;
        ax3.MinorGridColor = [0.70 0.76 0.84];
        ax3.MinorGridAlpha = 0.24;
        ax3.Box = 'on';
        grid(ax3,'on');
        ax3.XMinorGrid = 'on';
        ax3.YMinorGrid = 'on';
        ax3.ZMinorGrid = 'on';
        hold(ax3,'on');
        view(ax3,[24 18]);
        axis(ax3,'vis3d');
        axis(ax3,'manual');
        xlim(ax3,[0 LoverD]);
        ylim(ax3,[-1.0 1.0]);
        zlim(ax3,[-0.85 0.85]);
        pbaspect(ax3,[LoverD 2.15 2.15]);
        xlabel(ax3,'x / D_h','FontWeight','bold');
        ylabel(ax3,'y / D_h','FontWeight','bold');
        zlabel(ax3,'z / D_h','FontWeight','bold');
        title(ax3,'3-D FLOW INSIDE A STRAIGHT CIRCULAR CONDUIT', ...
            'Color',[0.03 0.06 0.11],'FontWeight','bold');
    end

    function setupNavigation()
        % Enable mouse-based 3-D navigation and add a visible axes toolbar.
        try
            ax3.Interactions = [rotateInteraction panInteraction zoomInteraction];
        catch
            try
                enableDefaultInteractivity(ax3);
            catch
            end
        end
        try
            tb = axtoolbar(ax3,{'rotate','pan','zoomin','zoomout','restoreview'});
            tb.Visible = 'on';
        catch
            % Older MATLAB releases may not support axtoolbar on uiaxes.
        end
        try
            rotate3d(fig,'on');
        catch
        end
    end

    function setNavMode(modeName,isOn)
        if ~isOn
            if strcmp(modeName,'rotate')
                bRotate.Value = true;
            else
                bPan.Value = true;
            end
            return;
        end
        bRotate.Value = strcmp(modeName,'rotate');
        bPan.Value = strcmp(modeName,'pan');
        try
            rotate3d(fig,'off');
            pan(fig,'off');
            zoom(fig,'off');
        catch
        end
        switch modeName
            case 'rotate'
                try, rotate3d(fig,'on'); catch, end
                navHint.Text = 'ROTATE mode: drag inside the 3-D axes';
            case 'pan'
                try, pan(fig,'on'); catch, end
                navHint.Text = 'PAN mode: drag to move the camera target';
        end
    end

    function zoomInView(~,~)
        try
            camzoom(ax3,1.20);
        catch
            zoomAxesLimits(0.82);
        end
        navHint.Text = 'Zoomed in | use Zoom - or Reset 3-D view to return';
    end

    function zoomOutView(~,~)
        try
            camzoom(ax3,0.82);
        catch
            zoomAxesLimits(1.20);
        end
        navHint.Text = 'Zoomed out | drag to rotate or use Pan';
    end

    function zoomAxesLimits(factor)
        xl = xlim(ax3); yl = ylim(ax3); zl = zlim(ax3);
        xc = mean(xl); yc = mean(yl); zc = mean(zl);
        hx = diff(xl)*factor/2; hy = diff(yl)*factor/2; hz = diff(zl)*factor/2;
        xlim(ax3,[xc-hx xc+hx]);
        ylim(ax3,[yc-hy yc+hy]);
        zlim(ax3,[zc-hz zc+hz]);
    end

    function updateRegimeBanner(ReNow)
        if ReNow < 2300
            regimeBanner.BackgroundColor = [0.91 0.97 0.93];
            regimeGrid.BackgroundColor = [0.91 0.97 0.93];
            regimeLabel.FontColor = [0.05 0.30 0.13];
        elseif ReNow < 4000
            regimeBanner.BackgroundColor = [1.00 0.97 0.88];
            regimeGrid.BackgroundColor = [1.00 0.97 0.88];
            regimeLabel.FontColor = [0.42 0.26 0.03];
        else
            regimeBanner.BackgroundColor = [0.98 0.91 0.91];
            regimeGrid.BackgroundColor = [0.98 0.91 0.91];
            regimeLabel.FontColor = [0.42 0.05 0.05];
        end
    end

    function onTimer(~,~)
        if S.closed || ~isvalid(fig)
            return;
        end
        if S.paused
            S.lastClock = tic;
            return;
        end

        dtReal = toc(S.lastClock);
        S.lastClock = tic;
        dtReal = min(max(dtReal,0.005),0.08);
        dtSim = dtReal*S.visualTimeScale;
        S.t = S.t + dtSim;
        updateVisuals();
    end

    function updateVisuals()
        if ~isvalid(fig), return; end

        % Continuous fluid shells
        for kk = 1:nShells
            rn = rShell(kk)/R;
            localU = velocityProfile(rn,S.t);
            advPhase = 2*pi*(XX/LoverD*4.0 - transportPhase(localU));
            modWave = 1 + 0.08*cos(advPhase + 4.5*rn);
            Ck = localU*modWave;
            hShell(kk).CData = Ck;
        end

        % Bright inner core
        uCore = velocityProfile(rCore/R,S.t);
        hCore.CData = uCore*(1 + 0.10*cos(2*pi*(XX/LoverD*5.5 - transportPhase(uCore))));

        % Inlet / outlet discs
        rnDisc = min(RQ/R,1);
        Udisc = velocityProfile(rnDisc,S.t);
        hInlet.CData = Udisc;
        hOutlet.CData = Udisc;

        % Midplane slice
        localSlice = velocityProfile(rnSlice,S.t);
        advSlice = 1 + 0.07*cos(2*pi*(xSlice/LoverD*4.8 - transportPhase(S.U)) + 2.5*rnSlice);
        tmpSlice = nan(size(xSlice));
        tmpSlice(maskSlice) = localSlice(maskSlice).*advSlice(maskSlice);
        hSlice.CData = tmpSlice;

        % Streamlines / eddies: this is what makes laminar vs turbulent obvious.
        updateStreamlines();

        % Profile chart
        uDisp = velocityProfile(abs(rDisplay),S.t);
        hProfile.XData = uDisp;
        hMean.Value = S.U;
        xmin = min(-0.10*max(S.U,0.1),min(uDisp)*1.15);
        xmax = max(0.15,max(uDisp)*1.15);
        if xmax <= xmin, xmax = xmin + 0.1; end
        xlim(axP,[xmin xmax]);

        allVel = [uDisp(:); S.U; velocityProfile(rShell/R,S.t).'];
        uAbs = max(abs(allVel));
        if ~isfinite(uAbs) || uAbs < 0.05, uAbs = 0.05; end
        clim(ax3,[-0.05*uAbs 1.05*uAbs]);

        updateInfo();
        drawnow limitrate nocallbacks;
    end

    function updateStreamlines()
        lamW = max(0,min(1,(2600 - S.Re)/900));
        turbW = max(0,min(1,(S.Re - 2800)/2200));
        transW = max(0,1 - lamW - max(0,turbW-0.15));
        transW = max(0,min(1,transW));

        if S.Re < 2300
            regimeTxt = 'LAMINAR: straight parallel streamlines';
        elseif S.Re < 4000
            regimeTxt = 'TRANSITIONAL: disturbed / wavy streamlines';
        else
            regimeTxt = 'TURBULENT-LIKE: vortical swirling streamlines';
        end
        regimeLabel.Text = regimeTxt;
        updateRegimeBanner(S.Re);

        for ii = 1:Nlines
            r0 = lineR(ii);
            a0 = lineA(ii);
            xi = xLine;

            % Base straight line (laminar)
            yBase = r0*cos(a0)*ones(size(xi));
            zBase = r0*sin(a0)*ones(size(xi));

            % Transitional disturbance
            ampT = (0.012 + 0.018*(r0/R))*transW;
            phiT = 2*pi*(2.0*xi/LoverD - 0.55*S.t) + a0;
            yTrans = yBase + ampT*cos(phiT);
            zTrans = zBase + 0.75*ampT*sin(phiT + 0.8);

            % Turbulent-like vortical/helical motion
            ampV = (0.035 + 0.070*(r0/R))*turbW;
            phi1 = 2*pi*(3.0*xi/LoverD - 0.90*S.t) + 1.2*a0;
            phi2 = 2*pi*(6.2*xi/LoverD - 1.45*S.t) + 0.7*a0;
            yVort = yBase + ampV*(0.70*cos(phi1) + 0.30*cos(phi2));
            zVort = zBase + ampV*(0.70*sin(phi1 + 0.45) + 0.30*sin(phi2 + 1.05));

            % Blend by regime
            y = lamW*yBase + (1-lamW)*(0.45*yTrans + 0.55*yVort);
            z = lamW*zBase + (1-lamW)*(0.45*zTrans + 0.55*zVort);
            if transW > 0 && S.Re < 4000
                gamma = min(1,max(0,(S.Re-2300)/(4000-2300)));
                y = (1-gamma)*yTrans + gamma*yVort;
                z = (1-gamma)*zTrans + gamma*zVort;
            end

            [y,z] = clipInsidePipe(y,z,R*0.965);
            hLines(ii).XData = xi;
            hLines(ii).YData = y;
            hLines(ii).ZData = z;

            uLoc = velocityProfile(r0/R,S.t);
            c = speedToColor(uLoc);
            hLines(ii).Color = 0.15 + 0.85*c;
            hLines(ii).LineWidth = 1.5 + 1.2*turbW + 0.3*transW;
        end
    end

    function c = speedToColor(uVal)
        uRef = max(2*S.U,0.05);
        t = min(max(uVal/uRef,0),1);
        cmap = turbo(256);
        idx = max(1,min(256,1 + round(255*t)));
        c = cmap(idx,:);
    end

    function [y,z] = clipInsidePipe(y,z,Rlim)
        rr = sqrt(y.^2 + z.^2);
        bad = rr > Rlim;
        if any(bad)
            scl = Rlim./rr(bad);
            y(bad) = y(bad).*scl;
            z(bad) = z(bad).*scl;
        end
    end

    function ph = transportPhase(uVal)
        ph = (S.t*abs(uVal)/max(S.D,1e-6))/4.5;
    end

    function onTimerError(~,evt)
        try
            warning('PipeFlowSimulator:TimerError','Animation timer error: %s',evt.Data.Message);
        catch
        end
    end

    function val = reynolds(rho,U,D,mu)
        val = rho*U*D/mu;
    end

    function val = womersley(rho,mu,D,f)
        val = (D/2)*sqrt(2*pi*f*rho/mu);
    end

    function f = frequencyFromAlpha(alpha,rho,mu,D)
        omega = (alpha/(D/2))^2 * mu/rho;
        f = omega/(2*pi);
    end

    function setRe(v)
        S.Re = max(v,1e-6);
        S.U = S.Re*S.mu/(S.rho*S.D);
        updateAllUI('Re');
        updateVisuals();
    end

    function setAlpha(v)
        S.alpha = max(v,1e-4);
        S.f = frequencyFromAlpha(S.alpha,S.rho,S.mu,S.D);
        updateAllUI('alpha');
        updateVisuals();
    end

    function setU(v)
        S.U = max(v,1e-5);
        S.Re = reynolds(S.rho,S.U,S.D,S.mu);
        updateAllUI('U');
        updateVisuals();
    end

    function setMu(v_mPas)
        S.mu = max(v_mPas,1e-6)*1e-3;
        S.Re = reynolds(S.rho,S.U,S.D,S.mu);
        S.alpha = womersley(S.rho,S.mu,S.D,S.f);
        updateAllUI('mu');
        updateVisuals();
    end

    function setRho(v)
        S.rho = max(v,1e-3);
        S.Re = reynolds(S.rho,S.U,S.D,S.mu);
        S.alpha = womersley(S.rho,S.mu,S.D,S.f);
        updateAllUI('rho');
        updateVisuals();
    end

    function setD(v_mm)
        S.D = max(v_mm,1e-3)*1e-3;
        S.Re = reynolds(S.rho,S.U,S.D,S.mu);
        S.alpha = womersley(S.rho,S.mu,S.D,S.f);
        updateAllUI('D');
        updateVisuals();
    end

    function setAmp(v_percent)
        S.oscAmp = max(0,min(v_percent/100,0.95));
        updateAllUI('amp');
        updateVisuals();
    end

    function setPulse(tf)
        S.pulse = logical(tf);
        updateAllUI('pulse');
        updateVisuals();
    end

    function togglePause(~,~)
        S.paused = ~S.paused;
        if S.paused
            bPause.Text = 'Resume animation';
        else
            bPause.Text = 'Pause animation';
            S.lastClock = tic;
        end
    end

    function resetAnimation(~,~)
        S.t = 0;
        S.lastClock = tic;
        updateVisuals();
    end

    function resetView(~,~)
        try, rotate3d(fig,'off'); catch, end
        try, pan(fig,'off'); catch, end
        try, zoom(fig,'off'); catch, end
        view(ax3,[24 18]);
        xlim(ax3,[0 LoverD]);
        ylim(ax3,[-1.0 1.0]);
        zlim(ax3,[-0.85 0.85]);
        try, campos(ax3,'auto'); camtarget(ax3,'auto'); camup(ax3,'auto'); camva(ax3,'auto'); catch, end
        bRotate.Value = true;
        bPan.Value = false;
        try, rotate3d(fig,'on'); catch, end
        navHint.Text = 'ROTATE mode: drag inside the 3-D axes';
    end

    function closeApp(~,~)
        S.closed = true;
        try
            if exist('animTimer','var') && isvalid(animTimer)
                stop(animTimer);
                delete(animTimer);
            end
        catch
        end
        if isvalid(fig)
            delete(fig);
        end
    end

    function updateAllUI(owner)
        if nargin < 1, owner = ''; end

        sRe.Limits = adaptiveLimits(sRe.Limits,S.Re,1,5e6);
        sAlpha.Limits = adaptiveLimits(sAlpha.Limits,S.alpha,0.05,250);
        sU.Limits = adaptiveLimits(sU.Limits,S.U,0.001,20);

        if ~strcmp(owner,'Re'),    sRe.Value = clamp(S.Re,sRe.Limits); end
        if ~strcmp(owner,'alpha'), sAlpha.Value = clamp(S.alpha,sAlpha.Limits); end
        if ~strcmp(owner,'U'),     sU.Value = clamp(S.U,sU.Limits); end
        if ~strcmp(owner,'mu'),    sMu.Value = clamp(S.mu*1e3,sMu.Limits); end
        if ~strcmp(owner,'rho'),   sRho.Value = clamp(S.rho,sRho.Limits); end
        if ~strcmp(owner,'D'),     sD.Value = clamp(S.D*1e3,sD.Limits); end
        if ~strcmp(owner,'amp'),   sAmp.Value = clamp(100*S.oscAmp,sAmp.Limits); end
        switchPulse.Value = ternary(S.pulse,'Pulsatile','Steady');
        updateInfo();
    end

    function updateInfo()
        if S.Re < 2300
            regime = 'LAMINAR';
        elseif S.Re < 4000
            regime = 'TRANSITIONAL';
        else
            regime = 'TURBULENT-LIKE';
        end

        if S.pulse
            pulseText = sprintf('Pulsatile = ON    f = %.3f Hz',S.f);
        else
            pulseText = 'Pulsatile = OFF';
        end

        info.Value = {
            sprintf('Re        = %10.1f',S.Re)
            sprintf('alpha     = %10.3f',S.alpha)
            sprintf('U mean    = %10.4f m/s',S.U)
            sprintf('rho       = %10.1f kg/m^3',S.rho)
            sprintf('mu        = %10.4f mPa s',S.mu*1e3)
            sprintf('D_h       = %10.3f mm',S.D*1e3)
            pulseText
            sprintf('Regime    = %s',regime)};
    end

    function u = velocityProfile(rNorm,t)
        rNorm = min(max(rNorm,0),1);

        % Hagen-Poiseuille base
        uLam = 2*S.U*(1-rNorm.^2);

        % Turbulent-like power-law approximation
        n = max(6,min(12,7 + 0.9*log10(max(S.Re,4000)/4000 + 1)));
        a = 1/n;
        raw = max(1-rNorm,0).^a;
        areaMeanRaw = 2/((a+1)*(a+2));
        uTurb = S.U*raw/areaMeanRaw;

        if S.Re <= 2300
            uBase = uLam;
        elseif S.Re >= 4000
            uBase = uTurb;
        else
            beta = (S.Re-2300)/(4000-2300);
            beta = beta^2*(3-2*beta);
            uBase = (1-beta)*uLam + beta*uTurb;
        end

        if ~S.pulse || S.oscAmp <= 0 || S.f <= 0
            u = uBase;
            return;
        end

        alpha = max(S.alpha,1e-4);
        lambda = alpha*exp(1i*3*pi/4);
        J0wall = besselj(0,lambda);

        if abs(J0wall) < 1e-12
            H = 1-rNorm.^2;
        else
            H = 1-besselj(0,lambda*rNorm)./J0wall;
        end

        q = linspace(0,1,300);
        if abs(J0wall) < 1e-12
            Hq = 1-q.^2;
        else
            Hq = 1-besselj(0,lambda*q)./J0wall;
        end
        Hmean = 2*trapz(q,Hq.*q);
        if abs(Hmean) < 1e-10, Hmean = 1; end
        Hn = H./Hmean;

        omega = 2*pi*S.f;
        uOscMean = S.oscAmp*S.U;
        u = uBase + real(uOscMean*Hn.*exp(1i*omega*t));
    end

    function L = adaptiveLimits(L,current,minAllowed,maxAllowed)
        lo = L(1); hi = L(2);
        if current < lo, lo = max(minAllowed,0.75*current); end
        if current > hi, hi = min(maxAllowed,1.25*current); end
        if hi <= lo, hi = lo + max(abs(lo)*0.1,1e-3); end
        L = [lo hi];
    end

    function v = clamp(v,L)
        v = min(max(v,L(1)),L(2));
    end

    function out = ternary(cond,a,b)
        if cond, out = a; else, out = b; end
    end
end
