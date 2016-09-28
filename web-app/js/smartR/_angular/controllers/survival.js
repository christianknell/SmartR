
window.smartRApp.controller('SurvivalController',
    ['$scope', 'smartRUtils', 'commonWorkflowService', function($scope, smartRUtils, commonWorkflowService) {

        commonWorkflowService.initializeWorkflow('survival', $scope);

        // model
        $scope.conceptBoxes = {
            time: [],
            category: [],
            censoring: []
        };
        $scope.scriptResults = {};
    }]);
