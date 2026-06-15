local DamageSystem = {
    vehicleCondition = 100
}

function DamageSystem.applyDamage(amount)
    DamageSystem.vehicleCondition = DamageSystem.vehicleCondition - amount
    if DamageSystem.vehicleCondition < 0 then
        DamageSystem.vehicleCondition = 0
    end
end

function DamageSystem.getCondition()
    return DamageSystem.vehicleCondition
end

return DamageSystem
