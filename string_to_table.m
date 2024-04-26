function csv_table = string_to_table(csv_table, variable, variablename)

    C    = cell(height(csv_table), 1);
    C(:) = {variable};
    CT = cell2table(C, 'VariableNames', {variablename});
    csv_table = [CT, csv_table];
end