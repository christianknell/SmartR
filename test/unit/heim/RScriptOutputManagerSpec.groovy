package heim

import grails.test.mixin.TestMixin
import grails.test.mixin.support.GrailsUnitTestMixin
import org.rosuda.REngine.Rserve.RConnection
import spock.lang.Specification

/**
 * See the API for {@link grails.test.mixin.support.GrailsUnitTestMixin} for usage instructions
 */
@TestMixin(GrailsUnitTestMixin)
class RScriptOutputManagerSpec extends Specification {

    def setup() {

    }

    def cleanup() {
        new File("/tmp/heim/bogusfolder/init/plot.png").delete()
    }

    void "test getScriptOutput() returning single plot"() {
        given:
        def conn = new RConnection()
        conn.eval('png("plot.png")')
        conn.eval('plot(c(0,1),c(1,1))')
        conn.eval('dev.off()')
        def outputFolderName = "bogusfolder"
        def scripExecId = "init"
        def mngr = new RScriptOutputManager(conn, outputFolderName,scripExecId)

        when: ""
            def result = mngr.getScriptOutput()
        then: "Result is a list containing plot.png and only that one file."
            result
            result.size() == 1
            result[0] instanceof File
            result[0].getAbsolutePath() == '/tmp/heim/bogusfolder/init/plot.png'
    }
}
