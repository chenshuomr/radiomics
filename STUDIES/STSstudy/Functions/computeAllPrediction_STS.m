function computeAllPrediction_STS(pathWORK,fSetNameType,outcome,freedomMat,maxOrder,nBoot)
% -------------------------------------------------------------------------
% function computeAllPrediction_STS(pathWORK,fSetNameType,outcome,freedomMat,maxOrder,nBoot)
% -------------------------------------------------------------------------
% DESCRIPTION: 
% This function computes prediction performance estimation for a given 
% feature set type, and for all model orders of all experiments with 
% different degrees of freedom. See ref. [1] for more details.
% -------------------------------------------------------------------------
% REFERENCE:
% [1] Vallieres, M. et al. (2015). A radiomics model from joint FDG-PET and 
%     MRI texture features for the prediction of lung metastases in soft-tissue 
%     sarcomas of the extremities. Physics in Medicine and Biology, 60(14), 
%     5471-5496. doi:10.1088/0031-9155/60/14/5471
% -------------------------------------------------------------------------
% INPUTS:
% - pathWORK: Full path to the STS WORKSPACE directory.
% - fSetNameType: String specifying the name of the type of feature set 
%                 (e.g., 'PET', 'SEPARATE', 'FUSED', etc.)
% - outcome: Column vector of size [nInst X 1] specifying the outcome status 
%            (1 or 0) for all instances.
% - freedomMat:  Matrix of row vectors of 1's and 0's to specify the degree 
%                of freedom on texture extraction parameters for all 
%                experiments. For example, for an ith experiment where 
%                extraction parameters 1, 2 and 4 in paramAll are allowed 
%                to vary, use freedomMat(i,:) = [1,1,0,1].
% - maxOrder: Integer specifying the maximal multivariable model order 
%             to construct.
% - nBoot: Number of bootstrap samples to use.
% -------------------------------------------------------------------------
% OUTPUTS: Prediction performance results are saved in a folder named 
%          'RESULTS' in the STS WORKSPACE.
% -------------------------------------------------------------------------
% AUTHOR(S): Martin Vallieres <mart.vallieres@gmail.com>
% -------------------------------------------------------------------------
% HISTORY:
% - Creation: May 2015
%--------------------------------------------------------------------------
% STATEMENT:
% This file is part of <https://github.com/mvallieres/radiomics/>, 
% a package providing MATLAB programming tools for radiomics analysis.
% --> Copyright (C) 2015  Martin Vallieres
%
%    This package is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This package is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this package.  If not, see <http://www.gnu.org/licenses/>.
% -------------------------------------------------------------------------

startpath = pwd;
cd([pathWORK,'/MODELS']), pathModels = pwd;
cd([pathWORK,'/RESULTS']), pathResults = pwd;

nParamType = size(freedomMat,2);
nFreedom = size(freedomMat,1);
tStart = tic;
for i = 1:nFreedom
    cd(pathModels)
    results = struct;
    nameOpen = ['MODELS_',fSetNameType,'_'];
    for j = 1:nParamType
        nameOpen = [nameOpen,num2str(freedomMat(i,j))];
    end
    models = load(nameOpen); models = struct2cell(models); models = models{1};
    fprintf(['COMPUTING PREDICTION PERFORMANCE (MODEL ORDERS OF 1 to % u) FOR ',nameOpen,' ... '],maxOrder)
    tic
    for j = 1:maxOrder
        orderName = ['Order',num2str(j)];
        data = models.(orderName).Data;
        [orderResults] = predictionPerformanceEstimation(data,outcome,nBoot,'IABR');
        results.(orderName) = orderResults;
        results.(orderName).Data = models.(orderName).Data;
        results.(orderName).Name = models.(orderName).Name;
    end
    toc
    cd(pathResults)
    save(['RESULTS',nameOpen(7:end)],'results')
end
time = toc(tStart);
fprintf('TOTAL TIME: %.2f seconds\n',time)

cd(startpath)
end