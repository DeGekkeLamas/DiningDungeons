using Entities;
using Entities.StatusEffects;
using UnityEngine;

namespace InventoryStuff
{
    /// <summary>
    /// ScriptableObject for ConsumableItem
    /// </summary>
    [CreateAssetMenu(
        fileName = "ConsumableItem",
        menuName = "ScriptableObjects/Items/ConsumableItem",
        order = 0)]
    public class ConsumableItemData : InventoryItemData
    {
        public ConsumableItem item = new();
        public override InventoryItem GetItem() { return item; }
    }

    /// <summary>
    /// Itemtype that can recover HP when eaten
    /// </summary>
    [System.Serializable]
    public class ConsumableItem : InventoryItem
    {
        [Header("Type specific")]
        public float hpHealed;
        public StatusEffect[] effectsApplied = new StatusEffect[0];

        public override void UseItem(Entity source, Vector3 inputDir)
        {
            source.DealDamage(-hpHealed);
            for (int i = 0; i < effectsApplied.Length; i++)
            {
                source.activeStatusEffects.Add(effectsApplied[i]);
            }
            RemoveThisItem();
            canUseItem = false;
        }

        public override void UpdateAction()
        {
            canUseItem = true;
        }

        public override string GetItemDescription()
        {
            string description = base.GetItemDescription();

            // Healing
            description += $"Recovers {hpHealed} HP.\n";
            // Given effects
            foreach (StatusEffect effect in effectsApplied)
            {
                description += $"Gives {effect.name} effect.\n";
            }

            return description;

        }
    }

}
