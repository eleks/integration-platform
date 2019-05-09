/* api deployer */
//import org.wso2.carbon.utils.CarbonUtils
import org.wso2.carbon.apimgt.api.model.APIIdentifier
import  com.eleks.carbon.commons.util.CarbonUtil
import java.util.zip.ZipEntry
import java.util.zip.ZipFile
import java.util.zip.ZipInputStream

import org.wso2.carbon.context.CarbonContext
import org.wso2.carbon.context.PrivilegedCarbonContext

def getAPIImportUtil(){
	GroovyClassLoader gcl = this.getClass().getClassLoader()
	try{
		//maybe class already loaded - just return it
		return gcl.loadClass("org.wso2.carbon.apimgt.importexport.utils.APIImportUtil").newInstance()
	}catch(e){}
	//lookup api-import-export web application root
	File webappRoot = new File( CarbonUtil.getCarbonHome()+"/repository/deployment/server/webapps" )
	File webappApiRoot = webappRoot.listFiles().find{ it.isDirectory() && it.getName().startsWith("api-import-export-") }
	assert webappApiRoot!=null : "`api-import-export-*` folder not found in $webappRoot"
	//modifyclasspath to load api-import-export classes
	gcl.addClasspath( "${webappApiRoot}/WEB-INF/classes" )
	//maybe we have to load all jars in webapp but they are absent for now...
	//try to load and instantiate again
	return gcl.loadClass("org.wso2.carbon.apimgt.importexport.utils.APIImportUtil").newInstance()
}

File tmpDir(String prefix){
	File root = new File( CarbonUtil.getCarbonHome()+"/tmp/api-import" )
	root.mkdirs()
	//root.deleteOnExit()
	while(true){
		File d = new File(root, prefix+"#"+Long.toHexString(System.currentTimeMillis()))
		if(!d.exists()){
			d.mkdirs()
			return d
		}
		Thread.sleep(31)
	}
}
//returns root folder name
File unzip(File src, File dst, boolean verbose=false){
	String root = ""
	def zipFile = new ZipFile(src)
	try{
		zipFile.entries().each { ZipEntry entry->
			long lastModified = entry.getTime()
			if(lastModified==-1)lastModified=src.lastModified()
			def entryName = entry.getName().tr('\\','/')
			if(!root){
				int index = entryName.indexOf('/')
				if(index>0)root=entryName.substring(0,index)
			}
			File dstUnzip = new File(dst, entryName)
			if(entryName.endsWith('/')){
				dstUnzip.mkdirs()
			}else{
				if(verbose)println "     [entry] ${dstUnzip}"
				dstUnzip.getParentFile().mkdirs()
				dstUnzip.withOutputStream{ it << zipFile.getInputStream(entry) }
				dstUnzip.setLastModified( lastModified )
			}
		}
	}finally{
		zipFile.close()
	}
	return root ? new File(dst,root) : dst
}

// force async deploy/undeploy algorithm
boolean isAsync(){ true }

def deploy(){
	if( CarbonUtil.isServerStarted() ){
		ctx.apiImp = getAPIImportUtil()
		try{
			ctx.apiId = new APIIdentifier( ctx.file.getName().replaceAll(/\.[^\.]*$/,"") )
		}catch(e){throw new Exception("API filename must be: USER_APINAME_VERSION",e)}

		File tmpdir = tmpDir( ctx.file.getName().replaceAll(/\.[^\.]*$/,"") )
		try{
			//provide filename without extension (zip) as prefix
			File extractedFolderRoot = unzip(ctx.file, tmpdir)
			ctx.apiImp.initializeProvider( ctx.apiId.getProviderName() );
			ctx.apiImp.importAPI( extractedFolderRoot.getPath(), ctx.apiId.getProviderName(), true);
			tmpdir.deleteDir()
		}catch(Throwable t){
			if( !(t.message?.contains("A duplicate API already exists")) ){
				log.error "failed to import API from $tmpdir"
				throw t
			}
			//keep directory to investigate the problem
		}
	}else{
		//temporarily rename to wait file
		log.info("deploy   ${ctx.file.parentFile.name}/${ctx.file.name} postponed")
		ctx.fileWait = new File( ctx.file.toString()+".wait" )
		ctx.file.renameTo( ctx.fileWait )
		
		//def ctxLocal = ctx //to be available in thread `onServerStart`
		CarbonUtil.onServerStart{
			//server started - let's init deploy
			ctx.fileWait.renameTo( ctx.file )
			ctx.fileWait = null
		}
	}
}

def undeploy(){
	if(ctx.apiImp?.provider)ctx.apiImp.provider.deleteAPI( ctx.apiId )
}
