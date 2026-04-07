package service.pve;

import dto.pve.BuildDTO;
import dto.pve.GameState;
import java.util.List;
import java.util.Map;

public interface PveSimulationService {

    /**
     * 프리셋 빌드 기반 시뮬레이션 (컨디션 및 연승 파라미터 추가)
     */
    List<GameState> runFullSimulation(
            Map<String, Integer> myStats,
            Map<String, Integer> aiStats,
            BuildDTO myBuild,
            BuildDTO aiBuild,
            String myRace,
            String aiRace,
            String myPlayerName,
            String aiPlayerName,
            String myCondition,   // 추가됨
            int myWinStreak,      // 추가됨
            String aiCondition,   // 추가됨
            int aiWinStreak       // 추가됨
    );

    /** AI용 기본 빌드 자동 생성 */
    BuildDTO generateDefaultBuild(String race, String vsRace);
}