function moving_charge_fields

    % Generates polar plots of electric field magnitude (E/c)
    % and magnetic field magnitude (B), in units of 
    % Q/c(4*pi*epsilon_0*r^2)
    % for a moving point charge.

    % Particle speed is controlled by horizontal slider

    
    % Angular coordinate
    theta = linspace(0,2*pi,1000);

    % Figure
    fig = figure('Name','Fields of a Moving Charge',...
                 'NumberTitle','off',...
                 'Position',[100 100 1000 500]);

    % Electric-field polar plot
    pax1 = polaraxes('Parent',fig,...
                     'Position',[0.05 0.18 0.40 0.75]);

    % Magnetic-field polar plot
    pax2 = polaraxes('Parent',fig,...
                     'Position',[0.55 0.18 0.40 0.75]);

    % Initial beta
    beta = 0;

    [E,B] = fieldValues(beta,theta);

    pE = polarplot(pax1,theta,E,'LineWidth',2);
    title(pax1,'Electric Field Magnitude (E/c)');

    pB = polarplot(pax2,theta,B,'LineWidth',2);
    title(pax2,'Magnetic Field Magnitude (B)');

    % Slider
    sld = uicontrol(fig,...
        'Style','slider',...
        'Min',0,...
        'Max',0.999,...
        'Value',beta,...
        'Units','normalized',...
        'Position',[0.15 0.05 0.70 0.04]);

    % Text display
    txt = uicontrol(fig,...
        'Style','text',...
        'Units','normalized',...
        'Position',[0.40 0.00 0.20 0.04],...
        'String','v/c = 0.000');

    % Callback
    sld.Callback = @(src,evt) updatePlots(src);

    function updatePlots(src)

        beta = src.Value;

        [E,B] = fieldValues(beta,theta);

        pE.RData = E;
        pB.RData = B;

        txt.String = sprintf('v/c = %.3f',beta);

        drawnow;
    end

end

function [E,B] = fieldValues(beta,theta)

    % Relativistic electric field
    E0 = 1;

    E = E0*(1-beta^2) ./ ...
        (1 - beta^2*sin(theta).^2).^(3/2);

    % Magnetic field magnitude
    B = (beta) .* E .* abs(sin(theta));

end