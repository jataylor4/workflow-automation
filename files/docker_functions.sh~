drun() {
	# Initialize variables
	local name=""
	local image=""
	local enable_cuda=false
	local ports=("8888:8888" "6006:6006")
	local volumes=("$HOME/dockerx:/dockerx" "/data:/data")

	# Helper function to construct port mappings
	construct_ports() {
		local port_mappings=""
		for port in "${ports[@]}"; do
			port_mappings="$port_mappings -p $port"
		done
		echo "$port_mappings"
	}

	# Helper function to construct volume mappings
	construct_volumes() {
		local volume_mappings=""
		for volume in "${volumes[@]}"; do
			volume_mappings="$volume_mappings -v $volume"
		done
		echo "$volume_mappings"
	}

	# Parse arguments
	while [[ "$#" -gt 0 ]]; do
		case $1 in
		--name)
			name=$2
			shift 2
			;;
		--image)
			image=$2
			shift 2
			;;
		--cuda)
			enable_cuda=true
			shift
			;;
		*)
			echo "Unknown parameter passed: $1"
			exit 1
			;;
		esac
	done

	# Ensure name and image are provided
	if [[ -z "$name" || -z "$image" ]]; then
		echo "Both --name and --image are required."
		exit 1
	fi

	# Create dockerx directory if it doesn't exist
	mkdir -p "$HOME/dockerx"

	# Construct port and volume mappings
	local port_mappings=$(construct_ports)
	local volume_mappings=$(construct_volumes)

	# Base Docker command
	local docker_command="docker run -it --network=host --ipc=host --cap-add=SYS_PTRACE \
        --shm-size=16G --privileged --security-opt seccomp=unconfined --name $name \
        $port_mappings $volume_mappings"

	# Add specific device flags for non-CUDA runs
	if [ "$enable_cuda" = false ]; then
		docker_command="$docker_command --device=/dev/kfd --device=/dev/dri --group-add video"
	fi

	# Add CUDA support if specified
	if [ "$enable_cuda" = true ]; then
		docker_command="$docker_command --gpus all"
	fi

	# Append the image name
	docker_command="$docker_command $image"

	# Print the Docker command for debugging
	echo "Docker command: $docker_command"

	# Run the Docker command
	sudo bash -c "$docker_command"

	# Check if the Docker run command was successful
	if [[ $? -ne 0 ]]; then
		echo "Docker command failed. Please check the command and try again."
	fi
}
