% CarbEval - A class to evaluate the carbon footprint for multiple energy sources.
%
% Syntax:
%   obj = CarbEval();
%   result = obj.evaluate({'Electricity', 500, 'NaturalGas', 100, 'Fuel', 50});
%   obj.exportToCSV(result.IndividualSources, 'MyCarbonReport.csv');
%   obj.plotEmissions(result.IndividualSources.EnergySource, result.IndividualSources.Emissions_kgCO2e);
%
% Description:
%   This class calculates the carbon footprint for various energy sources using
%   defined emission factors. Users can evaluate sources, export results, and
%   visualize the breakdown using provided methods.
%
% Inputs:
%   Cell array of pairs: {'EnergySource1', Consumption1, 'EnergySource2', Consumption2, ...}
%   Supported sources: 'Electricity', 'NaturalGas', 'Fuel'
%   Units: Electricity in kWh, NaturalGas in therms, Fuel in liters
%
% Outputs:
%   Struct with:
%       - IndividualSources: table of emissions by source
%       - TotalEmissions: total carbon footprint in kgCO2e
%
% Example:
%   % Create an instance
%   obj = CarbEval();
%   % Evaluate emissions
%   result = obj.evaluate({'Electricity', 500, 'NaturalGas', 100, 'Fuel', 50});
%   % Display total
%   fprintf('Total Emissions: %.2f kgCO2e\n', result.TotalEmissions);
%   % Export results to a file
%   obj.exportToCSV(result.IndividualSources, 'MyCarbonReport.csv');
%   % Visualize the emissions
%   obj.plotEmissions(result.IndividualSources.EnergySource, result.IndividualSources.Emissions_kgCO2e);

classdef CarbEval
    % CarbEval - A class to evaluate the carbon footprint for multiple energy sources.

    properties
        % Emission factors (in kgCO2e per unit)
        EmissionFactors = struct('electricity', 0.4, ...      % kgCO2e per kWh
                                  'naturalgas', 5.3, ...      % kgCO2e per therm
                                  'fuel', 2.3);               % kgCO2e per liter
    end

    methods
        function CarbonFootprint = evaluate(obj, inputs)
            % Evaluate - Calculates carbon footprint for multiple energy sources.
            % Inputs:
            %   inputs - Cell array of EnergySource and Consumption pairs.
            % Outputs:
            %   CarbonFootprint - Struct with IndividualSources table and TotalEmissions.

            if mod(numel(inputs), 2) ~= 0
                error('Inputs must be provided as pairs of EnergySource and Consumption.');
            end

            total_emissions = 0;
            sources = {};
            emissions = [];

            for i = 1:2:numel(inputs)
                EnergySource = inputs{i};
                Consumption = inputs{i+1};

                if ~ischar(EnergySource)
                    error('EnergySource must be a character array.');
                end
                normalized = lower(EnergySource);
                if ~isfield(obj.EmissionFactors, normalized)
                    validSources = fieldnames(obj.EmissionFactors);
                    error('"%s" is not a recognized energy source. Valid options are: %s', ...
                          EnergySource, strjoin(validSources, ', '));
                end

                if ~isnumeric(Consumption) || Consumption < 0
                    error('Consumption must be a non-negative real number.');
                end

                current_emission = Consumption * obj.EmissionFactors.(normalized);
                total_emissions = total_emissions + current_emission;

                sources{end+1} = EnergySource; %#ok<AGROW>
                emissions(end+1) = current_emission; %#ok<AGROW>

                fprintf('Carbon Footprint for %s (%.2f units): %.2f kgCO2e\n', ...
                        EnergySource, Consumption, current_emission);
            end

            CarbonFootprint = struct('IndividualSources', table(sources', emissions', 'VariableNames', {'EnergySource', 'Emissions_kgCO2e'}), ...
                                      'TotalEmissions', total_emissions);

            fprintf('------------------------------------------------------------\n');
            fprintf('Total Carbon Footprint: %.2f kgCO2e\n', CarbonFootprint.TotalEmissions);
        end

        function exportToCSV(~, dataTable, filename)
            % exportToCSV - Exports the data table to a CSV file.
            % Inputs:
            %   dataTable - Table containing emissions data.
            %   filename - (Optional) Name of the output CSV file.

            if nargin < 3
                filename = 'CarbonFootprintResults.csv';
            end

            try
                writetable(dataTable, filename);
                fprintf('Results exported to %s\n', filename);
            catch ME
                warning('Failed to export data: %s', ME.message);
            end
        end

        function plotEmissions(~, sources, emissions)
            % plotEmissions - Plots a bar chart of carbon emissions.
            % Inputs:
            %   sources - Cell array of energy source names.
            %   emissions - Array of emission values.

            figure;
            b = bar(categorical(sources), emissions, 'FaceColor', [0.2 0.6 0.8]);
            title('Carbon Footprint Breakdown');
            ylabel('Emissions (kgCO2e)');
            xlabel('Energy Source');
            grid on;

            xtips = b.XEndPoints;
            ytips = b.YEndPoints;
            labels = string(b.YData);
            text(xtips, ytips, labels, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        end
    end
end
