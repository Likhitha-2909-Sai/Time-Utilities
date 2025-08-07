module address::TimeScheduler {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::error;
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_INVALID_TIME: u64 = 2;
    const E_TASK_NOT_FOUND: u64 = 3;
    struct ScheduledTask has store, key {
        creator: address,           
        scheduled_time: u64,        
        duration: u64,              
        is_active: bool,           
        created_at: u64,           
    }
    public fun create_scheduled_task(
        creator: &signer, 
        scheduled_time: u64, 
        duration: u64
    ) {
        let creator_addr = signer::address_of(creator);
        let current_time = timestamp::now_seconds();
        
        assert!(scheduled_time > current_time, error::invalid_argument(E_INVALID_TIME));
        
        let task = ScheduledTask {
            creator: creator_addr,
            scheduled_time,
            duration,
            is_active: true,
            created_at: current_time,
        };
        
        move_to(creator, task);
    }
    public fun is_task_ready(task_owner: address): bool acquires ScheduledTask {
        assert!(exists<ScheduledTask>(task_owner), error::not_found(E_TASK_NOT_FOUND));
        
        let task = borrow_global<ScheduledTask>(task_owner);
        let current_time = timestamp::now_seconds();
        
        task.is_active && current_time >= task.scheduled_time
    }

    #[view]
    public fun get_task_info(task_owner: address): (u64, u64, bool, u64) acquires ScheduledTask {
        assert!(exists<ScheduledTask>(task_owner), error::not_found(E_TASK_NOT_FOUND));
        
        let task = borrow_global<ScheduledTask>(task_owner);
        (task.scheduled_time, task.duration, task.is_active, task.created_at)
    }

}
