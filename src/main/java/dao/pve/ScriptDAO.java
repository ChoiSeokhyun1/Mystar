package dao.pve;

import dto.pve.BuildMatchupDTO;
import dto.pve.BuildStatBonusDTO;
import dto.pve.ScriptDTO;
import java.util.List;
import java.util.Map;

public interface ScriptDAO {

    // ── 대본 CRUD ─────────────────────────────────────────
    int insertScript(ScriptDTO script);
    int updateScript(ScriptDTO script);  // myBuildId+oppBuildId+result 기준
    int deleteScript(int scriptId);
    int deleteScriptsByMyBuildId(int myBuildId);
    
    /** myBuildId + oppBuildId 조합으로 삭제 (추가) */
    int deleteScriptsByBuildIds(Map<String, Object> params);

    /** myBuildId + oppBuildId 기준 전체 조회 (WIN/LOSE 모두) */
    List<ScriptDTO> selectScriptsByMatchup(Map<String, Object> params);

    /** myBuildId + oppBuildId + result 기준 단건 (랜덤 선택용: 여러 개면 랜덤) */
    List<ScriptDTO> selectScriptForPlay(Map<String, Object> params);

    /** myBuildId 기준 전체 대본 목록 (관리 화면용 — oppBuildName 포함) */
    List<ScriptDTO> selectScriptSummaryByMyBuild(int myBuildId);

    /** oppBuildId 기준 전체 대본 목록 (반대 방향 조회 — 동족전 대비) */
    List<ScriptDTO> selectScriptSummaryByOppBuild(int oppBuildId);

    // ── 빌드 상성 (추가됨) ────────────────────────────────────
    /** DB에서 빌드 vs 빌드 상성 단건 조회 */
    String getBuildMatchup(int myBuildId, int oppBuildId);

    // (참고: TBL_BUILD_MATCHUP 테이블 변경으로 인해 아래 기존 VS_RACE 메서드들은 오류가 날 수 있으니 나중에 정리해주세요)
    int insertOrUpdateMatchup(BuildMatchupDTO matchup);
    int deleteMatchupsByBuildId(int buildId);
    List<BuildMatchupDTO> selectMatchupsByBuildId(int buildId);

    // ── 빌드 능력치 가산점 ────────────────────────────────
    int insertOrUpdateStatBonus(BuildStatBonusDTO bonus);
    int deleteStatBonusesByBuildId(int buildId);
    List<BuildStatBonusDTO> selectStatBonusesByBuildId(int buildId);
}