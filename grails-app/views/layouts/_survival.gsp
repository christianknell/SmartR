
<script type="text/ng-template" id="survival">

    <div ng-controller="SurvivalController">

        <tab-container>

            <workflow-tab tab-name="Fetch Data" disabled="fetch.disabled">
                <concept-box style="display: inline-block;"
                             concept-group="fetch.conceptBoxes.time"
                             type="LD-numerical"
                             min="1"
                             max="1"
                             label="Time"
                             tooltip="Select time variable from the Data Set Explorer Tree and drag it into the box. For example, 'Survival Time'. This variable is required.">
                </concept-box>
                <concept-box style="display: inline-block;"
                             concept-group="fetch.conceptBoxes.category"
                             type="LD-categorical"
                             min="0"
							 max="4"
                             label="Category (optional)"
                             tooltip="Select a variable on which you would like to group the cohort and drag it into the box. For example, 'Cancer Stage'.">
                </concept-box>
                <concept-box style="display: inline-block;"
                             concept-group="fetch.conceptBoxes.censoring"
                             type="LD-categorical"
                             min="0"
                             max="1"
                             label="Censoring Variable (optional)"
                             tooltip="Drag the item for which to perform censoring in the analysis into this box. For example, when performing Overall survival analysis, drag 'Survival status = alive' into this box. This variable is not obligatory. ">
                </concept-box>
                <br/>
                <fetch-button concept-map="fetch.conceptBoxes"
                              loaded="fetch.loaded"
                              running="fetch.running"
                              allowed-cohorts="[1, 2]">
                </fetch-button>
            </workflow-tab>

            <workflow-tab tab-name="Run Analysis" disabled="runAnalysis.disabled">
                <div class="heim-input-field sr-input-area">
                    <h2>Legend Position:</h2>
                    <fieldset class="heim-radiogroup">
                        <label>
                            <input type="radio"
                                   ng-model="runAnalysis.params.legendPosition"
                                   value="top"> Top
                        </label>
                        <label>
                            <input type="radio"
                                   ng-model="runAnalysis.params.legendPosition"
                                   value="right" checked> Right
                        </label>
                        <label>
                            <input type="radio"
                                   ng-model="runAnalysis.params.legendPosition"
                                   value="bottom"> Bottom
                        </label>
                        <label>
                            <input type="radio"
                                   ng-model="runAnalysis.params.legendPosition"
                                   value="left"> Left
                        </label>
                    </fieldset>
                </div>
                <hr class="sr-divider">
                <run-button button-name="Create Plot"
                            store-results-in="runAnalysis.scriptResults"
                            script-to-run="run"
                            arguments-to-use="runAnalysis.params"
                            running="runAnalysis.running">
                </run-button>
                <br/>
                <br/>
                <survival-plot data="runAnalysis.scriptResults" width="1100" height="700"></survival-plot>
            </workflow-tab>

        </tab-container>

    </div>

</script>
