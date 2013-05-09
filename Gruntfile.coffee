module.exports = (grunt) ->
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-connect'
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-requirejs'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-mocha'
	grunt.loadNpmTasks 'grunt-smushit'

	grunt.initConfig
		clean:
			all : ['./dev/*', './production/*']
			dev : ['./dev/*']
			production : ['./production']

		connect:
			dev:
				options:
					port: 8000
					base: '.'
					keepalive: true
			test:
				options:
					port: 8000
					base: '.'

		copy:
			dev:
				files: [
					expand: true
					cwd: './src/app/assets'
					src: ['**']
					dest: './dev/app/assets'
				]
			templates:
				files: [
					expand: true
					cwd: './src/app/modules'
					src: ['**/*.html']
					dest: './dev/app/modules'
				]
			test:
				files: [
					expand: true
					cwd: './src/test/fixtures'
					src: ['**']
					dest: './dev/test/fixtures'
				]
			production:
				files: [
						expand: true
						cwd: './src/app/assets'
						src: ['**']
						dest: './production/app/assets'
				]

		smushit:
			production:
				src: './production/app/assets'

		requirejs:
			compile:
				options:
					baseUrl: './dev/app'
					mainConfigFile: './dev/app/main.js'
					out: './production/app/main.js'
					include: 'main'

		coffee:
			dev:
				files: [
					expand: true
					cwd: './src/'
					src: ['**/*.coffee']
					dest: './dev/'
					ext: '.js'
				]

		less:
			dev:
				files:
					'./dev/app/css/main.css': './src/app/css/main.less'
			production:
				options:
					yuicompress: true
				files:
					'./production/app/css/main.css': './src/app/css/main.less'

		mocha:
			test:
				options:
					urls: [ 'http://localhost:8000/test.html']
					reporter : 'Spec'

		watch:
			templates:
				files: './src/app/**/*.html'
				tasks: ['copy:templates']
				options:
					nospawn: true
			coffee:
				files: './src/app/**/*.coffee'
				tasks: []
				options:
					nospawn: true
			less:
				files: './src/**/*.less'
				tasks: ['less:dev']
			test:
				files: './src/test/**/*.coffee'
				tasks: ['test:watch']
				options:
					nospawn: true

	grunt.event.on 'watch', (action, filepath) ->
		cwd = 'src/'
		filepath = filepath.replace cwd, ''

		grunt.config.set 'coffee',
			changed:
				expand: true
				cwd: cwd
				src: filepath
				dest: './dev'
				ext: '.js'

		grunt.task.run 'coffee:changed' unless filepath.indexOf('.coffee') < 0

	grunt.registerTask 'default', [
		'dev'
		'connect:dev'
	]

	grunt.registerTask 'dev', [
		'clean:dev'
		'coffee'
		'less:dev'
		'copy:dev'
		'copy:templates'
	]

	grunt.registerTask 'production', [
		'clean:production'
		'test'
		'less:production'
		'copy:production'
		'copy:templates'
		'requirejs'
		'smushit:production'
	]

	grunt.registerTask 'test:watch', [
		'copy:test'
		'mocha'
	]

	grunt.registerTask 'test', [
		'coffee'
		'copy:test'
		'connect:test'
		'mocha'
	]