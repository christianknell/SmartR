//# sourceURL=survival.js

'use strict';

window.smartRApp.controller('SurvivalController', [
	'$scope',
	'smartRUtils',
	'commonWorkflowService',
	function($scope, smartRUtils, commonWorkflowService) {
		
		commonWorkflowService.initializeWorkflow('survival', $scope);
		
		$scope.fetch = {
			disabled: false,
			running: false,
			loaded: false,
			conceptBoxes: {
				time: {concepts: [], valid: false},
				category: {concepts: [], valid: true},
				censoring: {concepts: [], valid: true}
			}
		};
		
		$scope.runAnalysis = {
			disabled: true,
			running: false,
			scriptResults: {},
			params: {
				legendPosition: 'right'
			}
		};
		
		$scope.$watchGroup(['fetch.running', 'runAnalysis.running'],
			function(newValues) {
				var fetchRunning = newValues[0],
					runAnalysisRunning = newValues[1];
				
				// clear old results
				if (fetchRunning) {
					$scope.runAnalysis.scriptResults = {};
				}
				
				// disable tabs when certain criteria are not met
				$scope.fetch.disabled = runAnalysisRunning;
				$scope.runAnalysis.disabled = fetchRunning || !$scope.fetch.loaded;
			}
		);
		
	}]);
