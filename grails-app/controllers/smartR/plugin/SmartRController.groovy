package smartR.plugin

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONObject
import org.codehaus.groovy.grails.web.json.JSONArray
import groovy.json.JsonBuilder
import org.apache.commons.io.FilenameUtils


class SmartRController {

    def smartRService

    /**
    *   Renders the default view
    */
    def index = {
        def dir = smartRService.getScriptsFolder()
        def scriptList = new File(dir).list().findAll { it != 'Wrapper.R' && it != 'Sample.R' }
        [scriptList: scriptList]
    }

    /**
    *   Renders the actual visualization based on the chosen script and the results computed
    */
    def renderOutputDIV = {
        params.init = params.init == null ? true : params.init // defaults to true
        def (success, results) = smartRService.runScript(params)
        if (! success) {
            render results
        } else {
            render template: "/heimVisualizations/out${FilenameUtils.getBaseName(params.script)}",
                    model: [results: results]
        }
    }

    def updateOutputDIV = {
        params.init = false
        def (success, results) = smartRService.runScript(params)
        if (! success) {
            render new JsonBuilder([error: results]).toString()
        } else {
            render results
        }
    }

    def recomputeOutputDIV = {
        params.init = false
        redirect controller: 'SmartR',
                 action: 'renderOutputDIV', 
                 params: params
    }
    
    /**
    *   Renders the input form for initial script parameters
    */
    def renderInputDIV = {
        if (! params.script) {
            render 'Please select a script to execute.'
        } else {
            render template: "/heim/in${FilenameUtils.getBaseName(params.script)}"
        }
    }

    def renderLoadingScreen = {
        render template: "/visualizations/outLoading"
    }

    /**
    *   Called to get the path to smartR.js such that the plugin can be loaded in the datasetExplorer
    */
    def loadScripts = {
        JSONArray files = new JSONArray()
        JSONObject result = new JSONObject()
        JSONObject script1 = new JSONObject()
        JSONObject script2 = new JSONObject()
        JSONObject script3 = new JSONObject()
        JSONObject script4 = new JSONObject()



        script1.put("path", "${servletContext.contextPath}${pluginContextPath}/js/resource/HighDimensionalData.js" as String)
        script1.put("type", "script")
        files << script1

        script2.put("path", "${servletContext.contextPath}${pluginContextPath}/js/resource/RmodulesView.js" as String)
        script2.put("type", "script")
        files << script2

        script3.put("path", "${servletContext.contextPath}${pluginContextPath}/js/resource/dataAssociation.js" as String)
        script3.put("type", "script")
        files << script3

        script4.put("path", "${servletContext.contextPath}${pluginContextPath}/js/smartR/smartR.js" as String)
        script4.put("type", "script")
        files << script4

        result.put("success", true)
        //result.put("files", new JSONArray() << script)
        result.put("files", files)

        render result as JSON;
    }
}
