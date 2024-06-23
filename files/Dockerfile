# Base image argument with default value
ARG BASE_IMAGE=rocm/dev-ubuntu-20.04:latest
FROM ${BASE_IMAGE}

# Arguments for platform and architecture
ARG PLATFORM
ARG ARCH

USER root

# Expose ports for Jupyter (8888) and TensorBoard (6006)
EXPOSE 8888 6006

# Determine platform and architecture if not provided
RUN if [ -z "${PLATFORM}" ]; then \
        if command -v rocminfo &> /dev/null; then \
            PLATFORM=rocm; \
        else \
            PLATFORM=cuda; \
        fi \
    fi && \
    if [ -z "${ARCH}" ]; then \
        if [ "${PLATFORM}" = "rocm" ]; then \
            ARCH="gfx90a;gfx940;gfx941;gfx942;gfx1100"; \
        else \
            ARCH="7.0;8.0;9.0"; \
        fi \
    fi

# Set environment variables based on platform
RUN if [ "${PLATFORM}" = "rocm" ]; then \
        export ROCM_PATH=/opt/rocm && \
        export ROCM_HOME=${ROCM_PATH} && \
        export PYTORCH_ROCM_ARCH=${ARCH} && \
        export PATH=${ROCM_PATH}/bin:${PATH} && \
        export LD_LIBRARY_PATH=${ROCM_PATH}/lib:${LD_LIBRARY_PATH}; \
    else \
        export CUDA_PATH=/usr/local/cuda && \
        export CUDA_HOME=${CUDA_PATH} && \
        export TORCH_CUDA_ARCH_LIST=${ARCH} && \
        export PATH=${CUDA_PATH}/bin:${PATH} && \
        export LD_LIBRARY_PATH=${CUDA_PATH}/lib64:${LD_LIBRARY_PATH}; \
    fi

# Install default libs and tools
RUN git clone https://github.com/jataylo/automation-tools /automation-tools && \
    cd /automation-tools && ./setup.sh 

# Start default shell
CMD ["sh", "-c", "exec $SHELL"]

