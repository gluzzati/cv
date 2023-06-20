job("build!") {
    container(image = "blang/latex:ubuntu"){
		shellScript {
			content = """
				bash install_roboto.sh
    			make all
       			zip -r artifacts.zip artifacts
   			"""
          }
        fileArtifacts {
            localPath = "artifacts.zip"
            remotePath = "{{ run:number }}/artifacts.zip"
		}
  	}
}