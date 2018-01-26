module.exports = function(grunt) {

	grunt.initConfig({
		watchify: {
			options: {
				debug: false,
				callback: function(b) {
					b.transform("browserify-shim", {"React": "global:React"})
					b.transform("reactify", {extension: ".jsx"});
					return b;
				}
			},
			portada: {
				src: './js/portada.js',
				dest: './public/js/portada.js'
			},
			item: {
				src: './js/one.js',
				dest: './public/js/one.js'
			}/*,
			jquery: {
				src: './js/jquery.js',
				dest: './public/js/jquery.js'
			}*/
		}, // Watchify
		sass: {
			dist: {
				options: {
					style: 'compressed',
					sourcemap: 'none'
				},
				files: [{
					expand: true,
					cwd: 'css/',
					src: ['**/*.scss'],
					dest: 'public/css/',
					ext: '.css'
				}]
			}
		},
		watch: {
			css: {
				files: "css/**/*.scss",
				tasks: ['sass']
			},
			js: {
				files: ["js/**/*.js", "js/**/*.jsx"],
				tasks: ["watchify"]
			}
		}
	});

	grunt.loadNpmTasks('grunt-contrib-sass');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-watchify');
	grunt.registerTask('default', ['watch']);

};