
secure_shared_memory() {
    echo "--- Securing Shared Memory ---"
    
    # Check if /dev/shm is already configured in fstab
    if grep -q "/dev/shm" /etc/fstab; then
        echo "Shared memory already configured in fstab. Skipping."
    else
        echo "tmpfs /dev/shm tmpfs defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
        mount -o remount /dev/shm
        echo "Shared memory secured (noexec, nosuid, nodev)."
    fi
}
