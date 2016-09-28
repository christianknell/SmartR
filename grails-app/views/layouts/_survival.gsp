
<script type="text/ng-template" id="survival">

    <div ng-controller="SurvivalController">

        <tab-container>

            <workflow-tab tab-name="Fetch Data">
                <concept-box style="display: inline-block;"
                             concept-group="conceptBoxes.time"
                             type="LD-numerical"
                             min="1"
                             max="1"
                             label="Time"
                             tooltip="Select time variable from the Data Set Explorer Tree and drag it into the box. For example, 'Survival Time'. This variable is required.">
                </concept-box>
                <concept-box style="display: inline-block;"
                             concept-group="conceptBoxes.category"
                             type="LD-categorical"
                             min="0"
                             max="1"
                             label="Category (optional)"
                             tooltip="Select a variable on which you would like to sort the cohort and drag it into the box. For example, 'Cancer Stage'.">
                </concept-box>
                <concept-box style="display: inline-block;"
                             concept-group="conceptBoxes.censoring"
                             type="LD-categorical"
                             min="1"
                             max="1"
                             label="Censoring Variable (optional)"
                             tooltip="Drag the item for which to perform censoring in the analysis into this box. For example, when performing Overall survival analysis, drag 'Survival status = alive' into this box. This variable is not obligatory. ">
                </concept-box>
                <br/>
                <fetch-button concept-map="conceptBoxes"
                              show-summary-stats="false"
                              disabled="false">
                </fetch-button>
            </workflow-tab>

            <workflow-tab tab-name="Run Analysis">
                <run-button button-name="Create Plot"
                            store-results-in="scriptResults"
                            script-to-run="run"
                            serialized="false"
                            disabled="false">
                </run-button>
                <br/>
                <br/>
                <survival-plot data="scriptResults" width="1200" height="1200"></survival-plot>
            </workflow-tab>

        </tab-container>

    </div>

</script>
