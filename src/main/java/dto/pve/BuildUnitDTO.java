package dto.pve;

import lombok.Data;

@Data
public class BuildUnitDTO {
    private int buildUnitId;
    private int buildId;
    private String phase;    // EARLY / MID / LATE
    private String unitId;   // zergling, hydralisk, mutalisk, lurker 등
    private int priority;    // 1=최우선 ~ 5=보조
}