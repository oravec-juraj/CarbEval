function CarbonFootprint = CarbEval(varargin)
% CarbEval - Evaluate the carbon footprint for multiple energy sources.
%
% Syntax:
%   CarbonFootprint = CarbEval('EnergySource1', Consumption1, ... , 'EnergySourceN', ConsumptionN)
%
% Inputs:
%   EnergySource - Type of energy source ('Electricity', 'NaturalGas', 'Fuel')
%   Consumption - Real-valued consumption of the energy source for each pair
%
% Output:
%   CarbonFootprint - A structure containing details about the carbon footprint
%                     of individual sources and the total carbon footprint.
%
% Example:
%   CarbonFootprint = CarbEval('Electricity', 500, 'NaturalGas', 100, 'Fuel', 50);

    % Validate the number of inputs
    if mod(numel(varargin), 2) ~= 0
        error('Inputs must be provided as pairs of EnergySource and Consumption.');
    end

    % Default emission factors (in kgCO2e per unit)
    emission_factors = struct('Electricity', 0.4, ...      % kgCO2e per kWh
                               'NaturalGas', 5.3, ...      % kgCO2e per therm
                               'Fuel', 2.3);               % kgCO2e per liter

    % Initialize total carbon footprint
    total_emissions = 0;

    % Initialize data for visualization and export
    sources = {};
    emissions = [];

    % Process each pair of inputs
    for i = 1:2:numel(varargin)
        EnergySource = varargin{i};
        Consumption = varargin{i+1};

        % Validate EnergySource
        if ~ischar(EnergySource) || ~ismember(EnergySource, fieldnames(emission_factors))
            error('EnergySource must be one of the following: ''Electricity'', ''NaturalGas'', or ''Fuel''.');
        end

        % Validate Consumption
        if ~isnumeric(Consumption) || Consumption < 0
            error('Consumption must be a non-negative real number.');
        end

        % Calculate and add to the total carbon footprint
        current_emission = Consumption * emission_factors.(EnergySource);
        total_emissions = total_emissions + current_emission;

        % Store data for visualization and export
        sources{end+1} = EnergySource; %#ok<AGROW>
        emissions(end+1) = current_emission; %#ok<AGROW>

        % Display the result for the current pair
        fprintf('Carbon Footprint for %s (%.2f units): %.2f kgCO2e\n', ...
                EnergySource, Consumption, current_emission);
    end

    % Create output structure
    CarbonFootprint = struct('IndividualSources', table(sources', emissions', 'VariableNames', {'EnergySource', 'Emissions_kgCO2e'}), ...
                              'TotalEmissions', total_emissions);

    % Display total carbon footprint
    fprintf('------------------------------------------------------------\n');
    fprintf('Total Carbon Footprint: %.2f kgCO2e\n', CarbonFootprint.TotalEmissions);

    % Data visualization: Bar chart
    figure;
    bar(categorical(sources), emissions);
    title('Carbon Footprint Breakdown');
    ylabel('Emissions (kgCO2e)');
    xlabel('Energy Source');
    grid on;

    % Export data to CSV file
    output_filename = 'CarbonFootprintResults.csv';
    writetable(CarbonFootprint.IndividualSources, output_filename);
    fprintf('Results exported to %s\n', output_filename);
end
