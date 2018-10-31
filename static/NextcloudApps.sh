for app in "${!NextcloudApps[@]}"; do
	case "$app" in 
		PreviewGenerator)
			echo "Installation of $app not implemented yet!"
		;;
		Tasks)
			echo "Installation of $app not implemented yet!"
		;;
		
		Bitwarden)
			echo "Installation of $app not implemented yet!"
		;;
		
		Keeweb)
			echo "Installation of $app not implemented yet!"
		;;
		
		FullTextSearch)
			echo "Installation of $app not implemented yet!"
		;;
		
		*)
			install_and_enable_app "$app"
		;;
	esac			
done
