<template>
  <div class="center-profile-page">
    <div v-if="pageLoading" class="page-loading">
      <i class="el-icon-loading" />
      <span>个人中心加载中…</span>
    </div>

    <el-empty
      v-else-if="pageError"
      :description="pageError"
      :image-size="120"
    />

    <template v-else-if="profile">
      <section class="profile-hero">
        <div class="profile-hero__cover" :style="profileCoverStyle">
          <div class="profile-hero__cover-mask" />
          <div v-if="!profileCoverImage" class="profile-hero__cover-empty">
            <span>{{ isSelf ? '上传背景图，让你的主页更完整' : 'TA 还没有设置头图' }}</span>
          </div>
        </div>

        <div class="profile-hero__body">
          <div class="profile-avatar-shell">
            <el-avatar
              :size="112"
              :src="profileAvatar"
              icon="el-icon-user"
              class="profile-avatar"
            />
          </div>

          <div class="profile-summary-panel">
            <div class="profile-summary">
              <div class="profile-summary__top">
                <div class="profile-title-group">
                  <h1 class="profile-name">{{ profileDisplayName }}</h1>
                  <div class="profile-meta">
                    <span v-if="profile.username" class="meta-pill">@{{ profile.username }}</span>
                    <span v-if="locationText" class="meta-pill">
                      <i class="el-icon-location-outline" />
                      {{ locationText }}
                    </span>
                  </div>
                </div>

                <div class="profile-actions">
                  <template v-if="isSelf">
                    <div class="profile-action-buttons">
                      <el-button
                        plain
                        size="small"
                        class="header-action-btn"
                        @click="editDialogVisible = true"
                      >
                        编辑个人资料
                      </el-button>

                      <el-upload
                        class="profile-inline-uploader"
                        :action="ossUploadAction('avatar')"
                        :before-upload="beforeAvatarUpload"
                        :show-file-list="false"
                        :on-success="handleAvatarUploadSuccess"
                        :on-error="handleAvatarUploadError"
                      >
                        <el-button
                          plain
                          size="small"
                          class="header-action-btn"
                          :loading="avatarUploading"
                        >
                          编辑头像
                        </el-button>
                      </el-upload>

                      <el-upload
                        class="profile-inline-uploader"
                        :action="ossUploadAction('cover')"
                        :before-upload="beforeCoverUpload"
                        :show-file-list="false"
                        :on-success="handleCoverUploadSuccess"
                        :on-error="handleCoverUploadError"
                      >
                        <el-button
                          plain
                          size="small"
                          class="header-action-btn"
                          :loading="coverUploading"
                        >
                          编辑背景图
                        </el-button>
                      </el-upload>
                    </div>

                    <div class="identity-switch">
                      <span class="identity-switch__label">身份切换</span>
                      <el-radio-group v-model="displayModeValue" size="small">
                        <el-radio-button label="artist">画师</el-radio-button>
                        <el-radio-button label="client">用户</el-radio-button>
                      </el-radio-group>
                    </div>
                  </template>

                  <template v-else>
                    <el-button
                      size="small"
                      class="header-action-btn"
                      :type="isFollowingProfile ? '' : 'primary'"
                      :plain="isFollowingProfile"
                      :loading="followLoading"
                      @click="toggleFollowProfile"
                    >
                      {{ isFollowingProfile ? '已关注' : '关注' }}
                    </el-button>
                  </template>
                </div>
              </div>

              <p class="profile-bio" :class="{ 'is-empty': !profile.bio }">
                {{ profile.bio || '这个人还没有留下简介。' }}
              </p>

              <div class="profile-stats">
                <button type="button" class="stat-card is-link" @click="goFollows">
                  <span class="stat-card__value">{{ followStats.following }}</span>
                  <span class="stat-card__label">{{ isSelf ? '已关注' : '关注' }}</span>
                </button>

                <button type="button" class="stat-card is-link" @click="goFollows">
                  <span class="stat-card__value">{{ followStats.followers }}</span>
                  <span class="stat-card__label">粉丝</span>
                </button>

                <div class="stat-card">
                  <span class="stat-card__value">{{ portfolioCount }}</span>
                  <span class="stat-card__label">{{ portfolioLabel }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="profile-shell">
        <div class="profile-shell__tabs">
          <el-tabs v-model="activePrimaryTab" @tab-click="handlePrimaryTabChange">
            <el-tab-pane
              v-for="tab in primaryTabs"
              :key="tab.key"
              :label="tab.label"
              :name="tab.key"
            />
          </el-tabs>

          <div v-if="secondaryTabs.length" class="secondary-tabs">
            <button
              v-for="tab in secondaryTabs"
              :key="tab.key"
              type="button"
              class="secondary-tab"
              :class="{ 'is-active': activeSecondaryTab === tab.key }"
              @click="setSecondaryTab(tab.key)"
            >
              {{ tab.label }}
            </button>
          </div>
        </div>

        <div class="profile-shell__content">
          <template v-if="isSelf">
            <section v-if="activePrimaryTab === 'submissions'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">我的投稿</h2>
                  <p class="section-heading__desc">统一查看作品、橱窗与企划内容。</p>
                </div>
                <el-button
                  size="small"
                  type="primary"
                  @click="goPublishEntry(activeSecondaryTab)"
                >
                  {{ activeSecondaryTab === 'projects' ? '发布企划' : '去投稿' }}
                </el-button>
              </div>

              <div v-if="activeSecondaryTab === 'works'">
                <div v-if="works.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
                <div v-else-if="works.list.length" class="card-grid">
                  <article v-for="item in works.list" :key="item.id" class="content-card">
                    <div class="content-card__cover">
                      <img
                        v-if="item.photoUrl && !item.photoBroken"
                        :src="item.photoUrl"
                        alt=""
                        class="cover-img"
                        @error="handleCardImageError(item)"
                      >
                      <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                    </div>
                    <div class="content-card__body">
                      <div class="content-card__title">{{ item.title || '未命名作品' }}</div>
                      <div class="content-card__meta">
                        <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        <span v-if="item.fbdate" class="meta-note">{{ item.fbdate }}</span>
                      </div>
                    </div>
                  </article>
                </div>
                <el-empty v-else description="还没有投稿作品" :image-size="110" />
              </div>

              <div v-else-if="activeSecondaryTab === 'showcase'">
                <div v-if="showcase.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
                <div v-else-if="showcase.list.length" class="card-grid">
                  <article
                    v-for="item in showcase.list"
                    :key="item.id"
                    class="content-card is-clickable"
                    @click="goShowcaseDetail(item.id)"
                  >
                    <div class="content-card__cover">
                      <img
                        v-if="item.photoUrl && !item.photoBroken"
                        :src="item.photoUrl"
                        alt=""
                        class="cover-img"
                        @error="handleCardImageError(item)"
                      >
                      <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                      <span v-if="item.price" class="cover-price">¥{{ item.price }}</span>
                    </div>
                    <div class="content-card__body">
                      <div class="content-card__title">{{ item.name || '未命名橱窗' }}</div>
                      <div class="content-card__meta">
                        <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        <span v-if="item.status" class="meta-note">{{ item.status }}</span>
                      </div>
                    </div>
                  </article>
                </div>
                <el-empty v-else description="还没有橱窗投稿" :image-size="110" />
              </div>

              <div v-else>
                <div v-if="projects.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
                <div v-else-if="projects.list.length" class="project-list">
                  <article
                    v-for="item in projects.list"
                    :key="item.id"
                    class="project-card is-clickable"
                    @click="goProjectDetail(item.id)"
                  >
                    <div class="project-card__main">
                      <div class="project-card__title">{{ item.title }}</div>
                      <p class="project-card__desc">{{ item.description || '暂无企划描述' }}</p>
                    </div>
                    <div class="project-card__side">
                      <span v-if="item.status" class="project-status">{{ item.status }}</span>
                      <span class="project-budget">{{ formatBudget(item) }}</span>
                    </div>
                  </article>
                </div>
                <el-empty v-else description="还没有发布企划" :image-size="110" />
              </div>
            </section>

            <section v-else-if="activePrimaryTab === 'favorites'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">我的收藏</h2>
                  <p class="section-heading__desc">按内容类型集中查看收藏记录。</p>
                </div>
              </div>

              <div v-if="favorites.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <template v-else>
                <div v-if="activeSecondaryTab === 'works'">
                  <div v-if="favoriteWorks.length" class="card-grid">
                    <article v-for="item in favoriteWorks" :key="item.id" class="content-card">
                      <div class="content-card__cover">
                        <img
                          v-if="item.photoUrl && !item.photoBroken"
                          :src="item.photoUrl"
                          alt=""
                          class="cover-img"
                          @error="handleCardImageError(item)"
                        >
                        <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                      </div>
                      <div class="content-card__body">
                        <div class="content-card__title">{{ item.title || '未命名作品' }}</div>
                        <div class="content-card__meta">
                          <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        </div>
                      </div>
                    </article>
                  </div>
                  <el-empty v-else description="还没有收藏作品" :image-size="110" />
                </div>

                <div v-else-if="activeSecondaryTab === 'showcase'">
                  <div v-if="favoriteShowcase.length" class="card-grid">
                    <article
                      v-for="item in favoriteShowcase"
                      :key="item.id"
                      class="content-card is-clickable"
                      @click="goShowcaseDetail(item.wzids)"
                    >
                      <div class="content-card__cover">
                        <img
                          v-if="item.photoUrl && !item.photoBroken"
                          :src="item.photoUrl"
                          alt=""
                          class="cover-img"
                          @error="handleCardImageError(item)"
                        >
                        <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                        <span v-if="item.price" class="cover-price">¥{{ item.price }}</span>
                      </div>
                      <div class="content-card__body">
                        <div class="content-card__title">{{ item.title || '未命名橱窗' }}</div>
                        <div class="content-card__meta">
                          <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        </div>
                      </div>
                    </article>
                  </div>
                  <el-empty v-else description="还没有收藏橱窗" :image-size="110" />
                </div>

                <div v-else>
                  <div v-if="favoriteProjects.length" class="project-list">
                    <article
                      v-for="item in favoriteProjects"
                      :key="item.id"
                      class="project-card is-clickable"
                      @click="goProjectDetail(item.wzids)"
                    >
                      <div class="project-card__main">
                        <div class="project-card__title">{{ item.title || '未命名企划' }}</div>
                        <p class="project-card__desc">收藏的企划条目</p>
                      </div>
                    </article>
                  </div>
                  <el-empty v-else description="还没有收藏企划" :image-size="110" />
                </div>
              </template>
            </section>

            <section v-else-if="activePrimaryTab === 'cart'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">购物车</h2>
                  <p class="section-heading__desc">这里只展示加入购物车的橱窗商品。</p>
                </div>
                <el-button size="small" plain @click="$router.push('/showcase')">去逛橱窗</el-button>
              </div>

              <div v-if="cart.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="cart.list.length" class="stack-list">
                <article v-for="item in cart.list" :key="item.id" class="stack-card">
                  <img
                    v-if="item.photoUrl && !item.photoBroken"
                    :src="item.photoUrl"
                    class="stack-card__thumb"
                    alt=""
                    @error="handleCardImageError(item)"
                  >
                  <div v-else class="stack-card__thumb stack-card__thumb--empty">
                    <span class="stack-card__thumb-label">暂无封面</span>
                  </div>
                  <div class="stack-card__main">
                    <div class="stack-card__title">{{ item.name || '未命名商品' }}</div>
                    <div class="stack-card__meta">
                      <span class="price-text">¥{{ item.price || 0 }}</span>
                      <span v-if="item.xddate" class="meta-note">{{ item.xddate }}</span>
                    </div>
                  </div>
                  <div class="stack-card__actions">
                    <el-button size="mini" type="primary" @click="openOrdersTab">去支付</el-button>
                    <el-button size="mini" type="text" @click="removeCartItem(item)">移除</el-button>
                  </div>
                </article>
              </div>
              <el-empty v-else description="购物车还是空的" :image-size="110" />
            </section>

            <section v-else class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">订单</h2>
                  <p class="section-heading__desc">统一查看买家或画师视角下的订单记录。</p>
                </div>

                <el-radio-group
                  v-if="hasArtistRole"
                  v-model="orderViewRole"
                  size="small"
                >
                  <el-radio-button label="用户角色">买家</el-radio-button>
                  <el-radio-button label="画师角色">画师</el-radio-button>
                </el-radio-group>
              </div>

              <div v-if="orders.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <el-table v-else-if="orders.list.length" :data="orders.list" class="orders-table">
                <el-table-column prop="name" label="订单内容" min-width="160" show-overflow-tooltip />
                <el-table-column label="价格" width="110">
                  <template slot-scope="{ row }">
                    <span class="price-text">¥{{ row.price || 0 }}</span>
                  </template>
                </el-table-column>
                <el-table-column prop="status" label="状态" width="120">
                  <template slot-scope="{ row }">
                    <el-tag size="small" :type="statusTagType(row.status)">{{ row.status }}</el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="xddate" label="时间" min-width="160" />
              </el-table>
              <el-empty v-else description="还没有订单记录" :image-size="110" />
            </section>
          </template>

          <template v-else>
            <section v-if="activePrimaryTab === 'home'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">主页</h2>
                  <p class="section-heading__desc">公开展示该用户的资料与内容概览。</p>
                </div>
              </div>

              <div class="overview-panels">
                <article class="overview-panel">
                  <div class="overview-panel__label">公开作品</div>
                  <div class="overview-panel__value">{{ works.total }}</div>
                  <el-button type="text" @click="activePrimaryTab = 'works'">查看作品</el-button>
                </article>
                <article class="overview-panel">
                  <div class="overview-panel__label">公开橱窗</div>
                  <div class="overview-panel__value">{{ showcase.total }}</div>
                  <el-button type="text" @click="activePrimaryTab = 'showcase'">查看橱窗</el-button>
                </article>
                <article v-if="hasPublicProjects" class="overview-panel">
                  <div class="overview-panel__label">公开企划</div>
                  <div class="overview-panel__value">{{ projects.total }}</div>
                  <el-button type="text" @click="activePrimaryTab = 'projects'">查看企划</el-button>
                </article>
              </div>

              <div class="home-sections">
                <div class="home-block">
                  <div class="home-block__header">
                    <h3>作品</h3>
                    <button type="button" class="link-btn" @click="activePrimaryTab = 'works'">全部作品</button>
                  </div>
                  <div v-if="works.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
                  <div v-else-if="works.list.length" class="card-grid">
                    <article v-for="item in works.list.slice(0, 4)" :key="item.id" class="content-card">
                      <div class="content-card__cover">
                        <img
                          v-if="item.photoUrl && !item.photoBroken"
                          :src="item.photoUrl"
                          alt=""
                          class="cover-img"
                          @error="handleCardImageError(item)"
                        >
                        <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                      </div>
                      <div class="content-card__body">
                        <div class="content-card__title">{{ item.title || '未命名作品' }}</div>
                        <div class="content-card__meta">
                          <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        </div>
                      </div>
                    </article>
                  </div>
                  <el-empty v-else description="暂无公开作品" :image-size="100" />
                </div>

                <div class="home-block">
                  <div class="home-block__header">
                    <h3>橱窗</h3>
                    <button type="button" class="link-btn" @click="activePrimaryTab = 'showcase'">全部橱窗</button>
                  </div>
                  <div v-if="showcase.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
                  <div v-else-if="showcase.list.length" class="card-grid">
                    <article
                      v-for="item in showcase.list.slice(0, 4)"
                      :key="item.id"
                      class="content-card is-clickable"
                      @click="goShowcaseDetail(item.id)"
                    >
                      <div class="content-card__cover">
                        <img
                          v-if="item.photoUrl && !item.photoBroken"
                          :src="item.photoUrl"
                          alt=""
                          class="cover-img"
                          @error="handleCardImageError(item)"
                        >
                        <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                        <span v-if="item.price" class="cover-price">¥{{ item.price }}</span>
                      </div>
                      <div class="content-card__body">
                        <div class="content-card__title">{{ item.name || '未命名橱窗' }}</div>
                        <div class="content-card__meta">
                          <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        </div>
                      </div>
                    </article>
                  </div>
                  <el-empty v-else description="暂无公开橱窗" :image-size="100" />
                </div>

                <div v-if="hasPublicProjects" class="home-block">
                  <div class="home-block__header">
                    <h3>企划</h3>
                    <button type="button" class="link-btn" @click="activePrimaryTab = 'projects'">全部企划</button>
                  </div>
                  <div v-if="projects.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
                  <div v-else-if="projects.list.length" class="project-list">
                    <article
                      v-for="item in projects.list.slice(0, 3)"
                      :key="item.id"
                      class="project-card is-clickable"
                      @click="goProjectDetail(item.id)"
                    >
                      <div class="project-card__main">
                        <div class="project-card__title">{{ item.title }}</div>
                        <p class="project-card__desc">{{ item.description || '暂无企划描述' }}</p>
                      </div>
                      <div class="project-card__side">
                        <span v-if="item.status" class="project-status">{{ item.status }}</span>
                        <span class="project-budget">{{ formatBudget(item) }}</span>
                      </div>
                    </article>
                  </div>
                  <el-empty v-else description="暂无公开企划" :image-size="100" />
                </div>
              </div>
            </section>

            <section v-else-if="activePrimaryTab === 'works'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">作品</h2>
                  <p class="section-heading__desc">公开作品列表。</p>
                </div>
              </div>

              <div v-if="works.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="works.list.length" class="card-grid">
                <article v-for="item in works.list" :key="item.id" class="content-card">
                  <div class="content-card__cover">
                    <img
                      v-if="item.photoUrl && !item.photoBroken"
                      :src="item.photoUrl"
                      alt=""
                      class="cover-img"
                      @error="handleCardImageError(item)"
                    >
                    <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                  </div>
                  <div class="content-card__body">
                    <div class="content-card__title">{{ item.title || '未命名作品' }}</div>
                    <div class="content-card__meta">
                      <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                    </div>
                  </div>
                </article>
              </div>
              <el-empty v-else description="暂无公开作品" :image-size="110" />
            </section>

            <section v-else-if="activePrimaryTab === 'showcase'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">橱窗</h2>
                  <p class="section-heading__desc">公开上架中的橱窗内容。</p>
                </div>
              </div>

              <div v-if="showcase.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="showcase.list.length" class="card-grid">
                <article
                  v-for="item in showcase.list"
                  :key="item.id"
                  class="content-card is-clickable"
                  @click="goShowcaseDetail(item.id)"
                >
                  <div class="content-card__cover">
                    <img
                      v-if="item.photoUrl && !item.photoBroken"
                      :src="item.photoUrl"
                      alt=""
                      class="cover-img"
                      @error="handleCardImageError(item)"
                    >
                    <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                    <span v-if="item.price" class="cover-price">¥{{ item.price }}</span>
                  </div>
                  <div class="content-card__body">
                    <div class="content-card__title">{{ item.name || '未命名橱窗' }}</div>
                    <div class="content-card__meta">
                      <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                    </div>
                  </div>
                </article>
              </div>
              <el-empty v-else description="暂无公开橱窗" :image-size="110" />
            </section>

            <section v-else class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">企划</h2>
                  <p class="section-heading__desc">公开企划列表。</p>
                </div>
              </div>

              <div v-if="projects.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="projects.list.length" class="project-list">
                <article
                  v-for="item in projects.list"
                  :key="item.id"
                  class="project-card is-clickable"
                  @click="goProjectDetail(item.id)"
                >
                  <div class="project-card__main">
                    <div class="project-card__title">{{ item.title }}</div>
                    <p class="project-card__desc">{{ item.description || '暂无企划描述' }}</p>
                  </div>
                  <div class="project-card__side">
                    <span v-if="item.status" class="project-status">{{ item.status }}</span>
                    <span class="project-budget">{{ formatBudget(item) }}</span>
                  </div>
                </article>
              </div>
              <el-empty v-else description="暂无公开企划" :image-size="110" />
            </section>
          </template>
        </div>
      </section>

      <el-dialog
        :visible.sync="editDialogVisible"
        title="编辑个人资料"
        width="560px"
        destroy-on-close
      >
        <el-form ref="editForm" :model="editForm" label-width="84px" class="edit-form">
          <div class="edit-form__hint">头像和背景图请在资料头部直接上传，这里只修改基础资料。</div>
          <el-form-item label="用户名">
            <el-input v-model="editForm.username" disabled />
          </el-form-item>
          <el-form-item label="昵称">
            <el-input v-model="editForm.name" placeholder="请输入昵称" />
          </el-form-item>
          <el-form-item label="邮箱">
            <el-input v-model="editForm.email" placeholder="请输入邮箱" />
          </el-form-item>
          <el-form-item label="电话">
            <el-input v-model="editForm.phone" placeholder="请输入电话" />
          </el-form-item>
          <el-form-item label="简介">
            <el-input
              v-model="editForm.bio"
              type="textarea"
              :rows="4"
              maxlength="500"
              show-word-limit
              placeholder="介绍一下自己"
            />
          </el-form-item>
          <el-form-item label="风格标签">
            <el-input
              v-model="editForm.styleTags"
              placeholder="多个标签用逗号分隔，例如：国风,厚涂,Q版"
            />
          </el-form-item>
        </el-form>

        <div slot="footer" class="dialog-footer">
          <el-button @click="editDialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="saving" @click="handleSaveProfile">保存</el-button>
        </div>
      </el-dialog>
    </template>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import userApi from '@/api/userManage'
import followApi from '@/api/follow'
import fenxiangApi from '@/api/fenxiang'
import huagaoApi from '@/api/huagao'
import projectApi from '@/api/project'
import shoucangApi from '@/api/shoucang'
import orderApi from '@/api/order'
import { extractUploadFileName, normalizeImageUrl, ossUploadAction } from '@/utils/oss'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

function createListState(pageSize = 8) {
  return {
    list: [],
    total: 0,
    pageNo: 1,
    pageSize,
    loading: false,
    loaded: false
  }
}

export default {
  name: 'CenterProfile',
  data() {
    return {
      defaultAvatar,
      pageLoading: true,
      pageError: '',
      currentUser: null,
      profile: null,
      profileUserId: null,
      isSelf: false,
      editDialogVisible: false,
      saving: false,
      avatarUploading: false,
      coverUploading: false,
      followLoading: false,
      isFollowingProfile: false,
      editForm: {
        id: null,
        username: '',
        name: '',
        email: '',
        phone: '',
        bio: '',
        styleTags: '',
        avatar: '',
        coverImage: ''
      },
      followStats: {
        following: 0,
        followers: 0
      },
      activePrimaryTab: 'submissions',
      activeSecondaryTab: 'works',
      orderViewRole: '用户角色',
      works: createListState(),
      showcase: createListState(),
      projects: createListState(),
      favorites: createListState(99),
      cart: createListState(6),
      orders: createListState(6)
    }
  },
  computed: {
    ...mapGetters(['token', 'userId', 'displayMode', 'roles', 'activeRole']),
    displayModeValue: {
      get() {
        return this.displayMode || 'client'
      },
      set(nextMode) {
        this.handleDisplayModeChange(nextMode)
      }
    },
    hasArtistRole() {
      return Array.isArray(this.roles) && this.roles.includes('画师角色')
    },
    profileDisplayName() {
      if (!this.profile) return '用户'
      return this.profile.name || this.profile.username || '用户'
    },
    profileAvatar() {
      return normalizeImageUrl(this.profile && this.profile.avatar) || this.defaultAvatar
    },
    profileCoverImage() {
      if (!this.profile) return ''
      return normalizeImageUrl(this.profile.coverImage || this.profile.cover || this.profile.backgroundImage || this.profile.background)
    },
    profileCoverStyle() {
      if (!this.profileCoverImage) {
        return {}
      }
      return {
        backgroundImage: `linear-gradient(135deg, rgba(14, 29, 41, 0.12), rgba(14, 29, 41, 0.42)), url("${this.profileCoverImage}")`
      }
    },
    locationText() {
      if (!this.profile) return ''
      return this.profile.location || this.profile.region || this.profile.address || ''
    },
    portfolioCount() {
      if (this.isSelf) {
        return this.works.total + this.showcase.total + this.projects.total
      }
      return this.works.total + this.showcase.total
    },
    portfolioLabel() {
      return this.isSelf ? '投稿数' : '作品数'
    },
    primaryTabs() {
      if (this.isSelf) {
        return [
          { key: 'submissions', label: '投稿' },
          { key: 'favorites', label: '收藏' },
          { key: 'cart', label: '购物车' },
          { key: 'orders', label: '订单' }
        ]
      }

      const tabs = [
        { key: 'home', label: '主页' },
        { key: 'works', label: '作品' },
        { key: 'showcase', label: '橱窗' }
      ]

      if (this.hasPublicProjects) {
        tabs.push({ key: 'projects', label: '企划' })
      }

      return tabs
    },
    secondaryTabs() {
      if (!this.isSelf) return []
      if (this.activePrimaryTab !== 'submissions' && this.activePrimaryTab !== 'favorites') return []

      return [
        { key: 'works', label: '作品' },
        { key: 'showcase', label: '橱窗' },
        { key: 'projects', label: '企划' }
      ]
    },
    favoriteWorks() {
      return this.favorites.list.filter(item => (!item.price || Number(item.price) === 0) && item.fenlei !== '企划')
    },
    favoriteShowcase() {
      return this.favorites.list.filter(item => item.price && Number(item.price) > 0)
    },
    favoriteProjects() {
      return this.favorites.list.filter(item => item.fenlei === '企划')
    },
    hasPublicProjects() {
      return this.projects.total > 0 || this.projects.list.length > 0
    }
  },
  watch: {
    '$route.fullPath': {
      immediate: true,
      handler() {
        this.initializePage()
      }
    },
    activePrimaryTab() {
      this.ensureSectionData()
    },
    orderViewRole(newValue, oldValue) {
      if (newValue !== oldValue && this.isSelf && this.activePrimaryTab === 'orders') {
        this.orders.pageNo = 1
        this.fetchOrders()
      }
    }
  },
  methods: {
    ossUploadAction,
    async initializePage() {
      this.pageLoading = true
      this.pageError = ''
      this.profile = null
      this.profileUserId = null
      this.isSelf = false
      this.isFollowingProfile = false
      this.followLoading = false
      this.editDialogVisible = false
      this.resetContentState()

      try {
        await this.ensureCurrentUser()

        const routeId = this.normalizeUserId(this.$route.params.id)
        const currentUserId = this.currentUser && this.currentUser.id ? Number(this.currentUser.id) : null

        if (!routeId || (currentUserId && routeId === currentUserId)) {
          if (routeId && currentUserId && String(this.$route.params.id) === String(currentUserId)) {
            this.$router.replace('/center/profile')
            return
          }

          if (!this.currentUser) {
            throw new Error('请先登录后再查看个人中心')
          }

          this.isSelf = true
          this.profileUserId = Number(this.currentUser.id)
          this.profile = { ...this.currentUser }
          this.orderViewRole = this.activeRole === '画师角色' && this.hasArtistRole ? '画师角色' : '用户角色'
        } else {
          this.isSelf = false
          this.profileUserId = routeId
          this.profile = await this.fetchOtherProfile(routeId)
          this.orderViewRole = '用户角色'
        }

        this.applyProfileToForm(this.profile)
        this.activePrimaryTab = this.isSelf ? 'submissions' : 'home'
        this.activeSecondaryTab = 'works'

        await Promise.all([
          this.fetchFollowStats(),
          this.fetchWorks(),
          this.fetchShowcase(),
          this.fetchProjects()
        ])

        if (!this.isSelf) {
          await this.checkFollowStatus()
        }

        if (!this.isSelf && this.activePrimaryTab === 'projects' && !this.hasPublicProjects) {
          this.activePrimaryTab = 'home'
        }
      } catch (error) {
        this.pageError = error && error.message ? error.message : '个人中心加载失败'
      } finally {
        this.pageLoading = false
      }
    },
    resetContentState() {
      this.works = createListState()
      this.showcase = createListState()
      this.projects = createListState()
      this.favorites = createListState(99)
      this.cart = createListState(6)
      this.orders = createListState(6)
    },
    normalizeUserId(value) {
      const numeric = Number(value)
      return Number.isFinite(numeric) && numeric > 0 ? numeric : null
    },
    async ensureCurrentUser() {
      if (this.currentUser && this.currentUser.id) return this.currentUser
      if (!this.token) return null

      const res = await userApi.getInfo(this.token)
      const user = res && res.data ? res.data.userList : null
      if (user) {
        this.currentUser = user
      }
      return user
    },
    async fetchOtherProfile(userId) {
      const res = await userApi.getUserById(userId)
      if (!res || !res.data) {
        throw new Error('用户不存在')
      }
      return res.data
    },
    applyProfileToForm(profile) {
      this.editForm = {
        id: profile && profile.id ? profile.id : null,
        username: profile && profile.username ? profile.username : '',
        name: profile && profile.name ? profile.name : '',
        email: profile && profile.email ? profile.email : '',
        phone: profile && profile.phone ? profile.phone : '',
        bio: profile && profile.bio ? profile.bio : '',
        styleTags: profile && profile.styleTags ? profile.styleTags : '',
        avatar: profile && profile.avatar ? profile.avatar : '',
        coverImage: profile && profile.coverImage ? profile.coverImage : ''
      }
    },
    async fetchFollowStats() {
      if (!this.profileUserId) return
      try {
        const res = await followApi.count(this.profileUserId)
        this.followStats = res.data || { following: 0, followers: 0 }
      } catch (error) {
        this.followStats = { following: 0, followers: 0 }
      }
    },
    normalizeMediaItem(item) {
      return {
        ...item,
        photoUrl: normalizeImageUrl(item && item.photo),
        photoBroken: false
      }
    },
    normalizeMediaList(list) {
      return Array.isArray(list) ? list.map(item => this.normalizeMediaItem(item)) : []
    },
    async fetchWorks() {
      this.works.loading = true
      try {
        const res = await fenxiangApi.getList({
          userids: this.profileUserId,
          pageNo: this.works.pageNo,
          pageSize: this.works.pageSize
        })
        this.works.list = this.normalizeMediaList(res.data.rows || [])
        this.works.total = res.data.total || 0
        this.works.loaded = true
      } finally {
        this.works.loading = false
      }
    },
    async fetchShowcase() {
      this.showcase.loading = true
      try {
        const params = {
          shangjiaids: String(this.profileUserId),
          pageNo: this.showcase.pageNo,
          pageSize: this.showcase.pageSize
        }

        if (!this.isSelf) {
          params.type = '上架'
          params.status = '审核成功'
        }

        const res = await huagaoApi.getList(params)
        this.showcase.list = this.normalizeMediaList(res.data.rows || [])
        this.showcase.total = res.data.total || 0
        this.showcase.loaded = true
      } finally {
        this.showcase.loading = false
      }
    },
    async fetchProjects() {
      this.projects.loading = true
      try {
        const res = await projectApi.getList({
          userId: this.profileUserId,
          pageNo: this.projects.pageNo,
          pageSize: this.projects.pageSize
        })
        this.projects.list = res.data.rows || []
        this.projects.total = res.data.total || 0
        this.projects.loaded = true
      } finally {
        this.projects.loading = false
      }
    },
    async fetchFavorites() {
      if (!this.isSelf || !this.profileUserId) return
      this.favorites.loading = true
      try {
        const res = await shoucangApi.getList({
          userids: this.profileUserId,
          pageNo: this.favorites.pageNo,
          pageSize: this.favorites.pageSize
        })
        this.favorites.list = this.normalizeMediaList(res.data.rows || [])
        this.favorites.total = res.data.total || 0
        this.favorites.loaded = true
      } finally {
        this.favorites.loading = false
      }
    },
    async fetchCart() {
      if (!this.isSelf || !this.profileUserId) return
      this.cart.loading = true
      try {
        const res = await orderApi.getList({
          userids: String(this.profileUserId),
          status: '购物车',
          pageNo: this.cart.pageNo,
          pageSize: this.cart.pageSize
        })
        this.cart.list = this.normalizeMediaList(res.data.rows || [])
        this.cart.total = res.data.total || 0
        this.cart.loaded = true
      } finally {
        this.cart.loading = false
      }
    },
    async fetchOrders() {
      if (!this.isSelf) return
      this.orders.loading = true
      try {
        const res = await orderApi.getMine({
          role: this.orderViewRole,
          pageNo: this.orders.pageNo,
          pageSize: this.orders.pageSize
        })
        this.orders.list = res.data.rows || []
        this.orders.total = res.data.total || 0
        this.orders.loaded = true
      } finally {
        this.orders.loading = false
      }
    },
    ensureSectionData() {
      if (!this.isSelf) return

      if ((this.activePrimaryTab === 'submissions' || this.activePrimaryTab === 'favorites') && !this.activeSecondaryTab) {
        this.activeSecondaryTab = 'works'
      }

      if (this.activePrimaryTab === 'favorites' && !this.favorites.loaded && !this.favorites.loading) {
        this.fetchFavorites()
      }

      if (this.activePrimaryTab === 'cart' && !this.cart.loaded && !this.cart.loading) {
        this.fetchCart()
      }

      if (this.activePrimaryTab === 'orders' && !this.orders.loaded && !this.orders.loading) {
        this.fetchOrders()
      }
    },
    handlePrimaryTabChange() {
      if (this.isSelf && (this.activePrimaryTab === 'submissions' || this.activePrimaryTab === 'favorites')) {
        this.activeSecondaryTab = this.activeSecondaryTab || 'works'
      }
      this.ensureSectionData()
    },
    setSecondaryTab(tabKey) {
      this.activeSecondaryTab = tabKey
    },
    handleCardImageError(item) {
      this.$set(item, 'photoBroken', true)
    },
    beforeAvatarUpload() {
      this.avatarUploading = true
      return true
    },
    beforeCoverUpload() {
      this.coverUploading = true
      return true
    },
    handleDisplayModeChange(nextMode) {
      if (nextMode === this.displayMode) return
      this.$store.commit('user/SET_DISPLAY_MODE', nextMode)
      const label = nextMode === 'artist' ? '画师' : '用户'
      this.$message.success(`已切换为${label}视图`)
    },
    buildProfilePayload(overrides = {}) {
      return {
        id: this.profile && this.profile.id ? this.profile.id : this.editForm.id,
        username: (this.profile && this.profile.username) || this.editForm.username || '',
        name: Object.prototype.hasOwnProperty.call(overrides, 'name') ? overrides.name : this.editForm.name,
        email: Object.prototype.hasOwnProperty.call(overrides, 'email') ? overrides.email : this.editForm.email,
        phone: Object.prototype.hasOwnProperty.call(overrides, 'phone') ? overrides.phone : this.editForm.phone,
        bio: Object.prototype.hasOwnProperty.call(overrides, 'bio') ? overrides.bio : this.editForm.bio,
        styleTags: Object.prototype.hasOwnProperty.call(overrides, 'styleTags') ? overrides.styleTags : this.editForm.styleTags,
        avatar: Object.prototype.hasOwnProperty.call(overrides, 'avatar') ? overrides.avatar : ((this.profile && this.profile.avatar) || this.editForm.avatar || ''),
        coverImage: Object.prototype.hasOwnProperty.call(overrides, 'coverImage') ? overrides.coverImage : ((this.profile && this.profile.coverImage) || this.editForm.coverImage || '')
      }
    },
    syncProfileState(profile) {
      if (!profile) return
      const nextProfile = { ...profile }
      this.profile = nextProfile
      if (this.isSelf) {
        this.currentUser = nextProfile
      }
      this.applyProfileToForm(nextProfile)
    },
    async refreshSelfProfile() {
      await this.$store.dispatch('user/getInfo')
      const res = await userApi.getInfo(this.token)
      const user = res && res.data ? res.data.userList : null
      if (user) {
        this.syncProfileState(user)
      }
    },
    async checkFollowStatus() {
      const followerId = this.userId || (this.currentUser && this.currentUser.id)
      if (!this.token || !followerId || !this.profileUserId || this.isSelf) {
        this.isFollowingProfile = false
        return
      }

      try {
        const res = await followApi.check({
          followerId,
          followingId: this.profileUserId
        })
        this.isFollowingProfile = !!(res && res.data)
      } catch (error) {
        this.isFollowingProfile = false
      }
    },
    async toggleFollowProfile() {
      const followerId = this.userId || (this.currentUser && this.currentUser.id)
      if (!this.token || !followerId) {
        this.$message.warning('请先登录')
        return
      }
      if (!this.profileUserId || this.isSelf) return

      this.followLoading = true
      try {
        if (this.isFollowingProfile) {
          await followApi.unfollow({
            followerId,
            followingId: this.profileUserId
          })
          this.isFollowingProfile = false
          this.$message.success('已取消关注')
        } else {
          await followApi.follow({
            followerId,
            followingId: this.profileUserId
          })
          this.isFollowingProfile = true
          this.$message.success('关注成功')
        }
        await this.fetchFollowStats()
      } catch (error) {
        this.$message.error('操作失败')
      } finally {
        this.followLoading = false
      }
    },
    async saveProfilePatch(overrides, successMessage) {
      this.saving = true
      try {
        await userApi.updateMyUser(this.buildProfilePayload(overrides))
        await this.refreshSelfProfile()
        this.$message.success(successMessage)
        return true
      } catch (error) {
        this.$message.error('保存失败')
        return false
      } finally {
        this.saving = false
      }
    },
    async updateMediaField(field, response, successMessage, loadingKey) {
      const fileName = extractUploadFileName(response)
      if (!fileName) {
        this[loadingKey] = false
        this.$message.error((response && response.message) || '上传失败')
        return
      }

      const nextUrl = normalizeImageUrl(fileName)
      if (!nextUrl) {
        this[loadingKey] = false
        this.$message.error('上传返回的图片地址无效')
        return
      }

      try {
        await userApi.updateMyUser(this.buildProfilePayload({ [field]: nextUrl }))
        await this.refreshSelfProfile()
        this.$message.success(successMessage)
      } catch (error) {
        this.$message.error('保存失败')
      } finally {
        this[loadingKey] = false
      }
    },
    handleAvatarUploadSuccess(response) {
      this.updateMediaField('avatar', response, '头像已更新', 'avatarUploading')
    },
    handleAvatarUploadError() {
      this.avatarUploading = false
      this.$message.error('头像上传失败')
    },
    handleCoverUploadSuccess(response) {
      this.updateMediaField('coverImage', response, '背景图已更新', 'coverUploading')
    },
    handleCoverUploadError() {
      this.coverUploading = false
      this.$message.error('背景图上传失败')
    },
    async handleSaveProfile() {
      const success = await this.saveProfilePatch({}, '个人资料已更新')
      if (success) {
        this.editDialogVisible = false
      }
    },
    goFollows() {
      this.$router.push('/center/follows')
    },
    goPublishEntry(type) {
      if (type === 'projects') {
        this.$router.push('/publish/project')
        return
      }
      const query = type === 'showcase' ? { type: 'huagao' } : undefined
      this.$router.push({ path: '/publish/work', query })
    },
    goShowcaseDetail(id) {
      if (!id) return
      this.$router.push('/work/' + id)
    },
    goProjectDetail(id) {
      if (!id) return
      this.$router.push('/project/' + id)
    },
    openOrdersTab() {
      const wasOrdersTab = this.activePrimaryTab === 'orders'
      this.activePrimaryTab = 'orders'
      if (wasOrdersTab) {
        this.fetchOrders()
      }
    },
    async removeCartItem(item) {
      try {
        await orderApi.deleteById(item.id)
        this.$message.success('已从购物车移除')
        this.fetchCart()
      } catch (error) {
        this.$message.error('移除失败')
      }
    },
    formatBudget(item) {
      const min = item && item.budgetMin ? item.budgetMin : null
      const max = item && item.budgetMax ? item.budgetMax : null
      if (min !== null && max !== null) return `预算 ¥${min} - ¥${max}`
      if (min !== null) return `预算 ¥${min} 起`
      if (max !== null) return `预算最高 ¥${max}`
      return '预算待沟通'
    },
    statusTagType(status) {
      const tagMap = {
        '待支付': 'warning',
        '已支付': 'success',
        '已完成': 'success',
        '已取消': 'info',
        '退款中': 'danger'
      }
      return tagMap[status] || ''
    }
  }
}
</script>

<style lang="scss" scoped>
.center-profile-page {
  padding: 12px 0 40px;
}

.page-loading {
  min-height: 360px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  color: #7b8796;
  font-size: 15px;
}

.profile-hero {
  overflow: visible;
}

.profile-hero__cover {
  position: relative;
  height: 260px;
  border-radius: 30px;
  overflow: hidden;
  background:
    radial-gradient(circle at top left, rgba(255, 203, 119, 0.9), transparent 35%),
    radial-gradient(circle at top right, rgba(65, 184, 131, 0.22), transparent 28%),
    linear-gradient(135deg, #1f5c4f 0%, #2e7d69 40%, #f5d48f 100%);
  background-size: cover;
  background-position: center;
  box-shadow: 0 18px 42px rgba(34, 46, 69, 0.14);
}

.profile-hero__cover-mask {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(180deg, rgba(13, 22, 28, 0.12) 0%, rgba(13, 22, 28, 0.34) 100%);
}

.profile-hero__cover-empty {
  position: absolute;
  right: 28px;
  bottom: 24px;
  z-index: 1;
  display: inline-flex;
  padding: 10px 16px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.16);
  backdrop-filter: blur(12px);
  color: #fff7e2;
  font-size: 13px;
}

.profile-hero__body {
  display: flex;
  gap: 28px;
  align-items: flex-end;
  padding: 0 28px;
  margin-top: -72px;
  position: relative;
  z-index: 2;
}

.profile-avatar-shell {
  flex-shrink: 0;
  align-self: flex-start;
  padding: 8px;
  border-radius: 32px;
  background: rgba(255, 255, 255, 0.95);
  box-shadow: 0 20px 38px rgba(34, 46, 69, 0.18);
}

.profile-avatar {
  display: block;
  border: 4px solid rgba(255, 255, 255, 0.88);
}

.profile-summary-panel {
  flex: 1;
  min-width: 0;
  border-radius: 28px;
  background: rgba(255, 255, 255, 0.96);
  box-shadow: 0 18px 42px rgba(34, 46, 69, 0.12);
  backdrop-filter: blur(10px);
}

.profile-summary {
  min-width: 0;
  padding: 24px 28px 26px;
}

.profile-summary__top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 20px;
}

.profile-title-group {
  min-width: 0;
}

.profile-name {
  margin: 0;
  font-size: 30px;
  font-weight: 700;
  color: #20313f;
}

.profile-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 10px;
}

.meta-pill {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 6px 12px;
  border-radius: 999px;
  background: #eef3f1;
  color: #55646f;
  font-size: 13px;
}

.profile-actions {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.profile-action-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  justify-content: flex-end;
}

.profile-inline-uploader {
  display: inline-flex;
}

.profile-inline-uploader ::v-deep .el-upload {
  display: inline-flex;
}

.header-action-btn {
  border-radius: 999px;
}

.identity-switch {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 12px;
  border-radius: 18px;
  background: #f6f8f7;
}

.identity-switch__label {
  font-size: 12px;
  color: #7b8796;
}

.profile-bio {
  margin: 18px 0 0;
  font-size: 14px;
  line-height: 1.75;
  color: #55646f;
}

.profile-bio.is-empty {
  color: #97a3ad;
}

.profile-stats {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
  margin-top: 22px;
}

.stat-card {
  border: 0;
  border-radius: 18px;
  padding: 18px 20px;
  text-align: left;
  background: #f7faf9;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.stat-card.is-link {
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 24px rgba(34, 46, 69, 0.08);
  }
}

.stat-card__value {
  font-size: 26px;
  font-weight: 700;
  color: #20313f;
}

.stat-card__label {
  font-size: 13px;
  color: #70808c;
}

.profile-shell {
  margin-top: 24px;
  background: #fff;
  border-radius: 24px;
  box-shadow: 0 14px 40px rgba(34, 46, 69, 0.08);
}

.profile-shell__tabs {
  padding: 24px 28px 0;
}

.profile-shell__tabs ::v-deep .el-tabs__nav-wrap::after {
  background: #edf1f0;
}

.profile-shell__tabs ::v-deep .el-tabs__item {
  font-size: 16px;
  font-weight: 600;
  color: #7b8796;
}

.profile-shell__tabs ::v-deep .el-tabs__item.is-active {
  color: #1f5c4f;
}

.profile-shell__tabs ::v-deep .el-tabs__active-bar {
  background: #1f5c4f;
}

.secondary-tabs {
  display: flex;
  gap: 10px;
  margin-top: 4px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.secondary-tab {
  border: 0;
  border-radius: 999px;
  padding: 8px 16px;
  background: #eef3f1;
  color: #70808c;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.secondary-tab.is-active {
  background: #1f5c4f;
  color: #fff;
}

.profile-shell__content {
  padding: 0 28px 28px;
}

.content-section {
  padding-top: 8px;
}

.section-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 22px;
}

.section-heading__title {
  margin: 0;
  font-size: 24px;
  font-weight: 700;
  color: #20313f;
}

.section-heading__desc {
  margin: 6px 0 0;
  color: #7b8796;
  font-size: 14px;
}

.content-loading {
  padding: 48px 0;
  text-align: center;
  color: #97a3ad;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 18px;
}

.content-card {
  border-radius: 18px;
  overflow: hidden;
  background: #fff;
  border: 1px solid #edf1f0;
  box-shadow: 0 8px 24px rgba(34, 46, 69, 0.05);
}

.content-card.is-clickable {
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;

  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 14px 28px rgba(34, 46, 69, 0.12);
  }
}

.content-card__cover {
  position: relative;
  padding-top: 100%;
  overflow: hidden;
  background: #eef3f1;
}

.cover-img,
.cover-fallback {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
}

.cover-img {
  object-fit: cover;
}

.cover-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  background:
    radial-gradient(circle at top left, rgba(245, 212, 143, 0.75), transparent 35%),
    linear-gradient(135deg, #dbe8e2 0%, #eef3f1 100%);
}

.cover-fallback__label {
  font-size: 12px;
  letter-spacing: 1px;
  color: #6f7d88;
}

.cover-price {
  position: absolute;
  right: 12px;
  bottom: 12px;
  padding: 4px 10px;
  border-radius: 999px;
  background: rgba(19, 28, 35, 0.72);
  color: #ffd88a;
  font-size: 12px;
  font-weight: 600;
}

.content-card__body {
  padding: 14px;
}

.content-card__title {
  font-size: 15px;
  font-weight: 600;
  color: #20313f;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.content-card__meta {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 10px;
  flex-wrap: wrap;
}

.meta-tag {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 999px;
  background: #eef3f1;
  color: #1f5c4f;
  font-size: 12px;
}

.meta-note {
  font-size: 12px;
  color: #97a3ad;
}

.project-list,
.stack-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.project-card,
.stack-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  padding: 18px 20px;
  border-radius: 18px;
  border: 1px solid #edf1f0;
  background: #fff;
  box-shadow: 0 8px 24px rgba(34, 46, 69, 0.05);
}

.project-card.is-clickable {
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 14px 28px rgba(34, 46, 69, 0.12);
  }
}

.project-card__main,
.stack-card__main {
  flex: 1;
  min-width: 0;
}

.project-card__title,
.stack-card__title {
  font-size: 16px;
  font-weight: 600;
  color: #20313f;
}

.project-card__desc {
  margin: 8px 0 0;
  color: #7b8796;
  font-size: 14px;
  line-height: 1.7;
}

.project-card__side {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 10px;
  flex-shrink: 0;
}

.project-status {
  padding: 4px 10px;
  border-radius: 999px;
  background: #ecf7f2;
  color: #1f8c68;
  font-size: 12px;
}

.project-budget {
  font-size: 13px;
  color: #7b8796;
}

.stack-card__thumb {
  width: 84px;
  height: 84px;
  border-radius: 14px;
  object-fit: cover;
  background: #eef3f1;
  flex-shrink: 0;
}

.stack-card__thumb--empty {
  display: flex;
  align-items: center;
  justify-content: center;
  background:
    radial-gradient(circle at top left, rgba(245, 212, 143, 0.75), transparent 35%),
    linear-gradient(135deg, #dbe8e2 0%, #eef3f1 100%);
}

.stack-card__thumb-label {
  font-size: 12px;
  color: #6f7d88;
}

.stack-card__meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 8px;
}

.stack-card__actions {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  flex-shrink: 0;
}

.price-text {
  color: #d86d3e;
  font-weight: 600;
}

.orders-table {
  width: 100%;
}

.overview-panels {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
  margin-bottom: 28px;
}

.overview-panel {
  padding: 18px 20px;
  border-radius: 18px;
  background: #f7faf9;
}

.overview-panel__label {
  font-size: 13px;
  color: #70808c;
}

.overview-panel__value {
  margin-top: 6px;
  font-size: 30px;
  font-weight: 700;
  color: #20313f;
}

.home-sections {
  display: flex;
  flex-direction: column;
  gap: 28px;
}

.home-block__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;

  h3 {
    margin: 0;
    font-size: 18px;
    color: #20313f;
  }
}

.link-btn {
  border: 0;
  padding: 0;
  background: transparent;
  color: #1f5c4f;
  font-size: 13px;
  cursor: pointer;
}

.edit-form {
  padding-top: 8px;
}

.edit-form__hint {
  margin-bottom: 18px;
  padding: 12px 14px;
  border-radius: 14px;
  background: #f7faf9;
  color: #70808c;
  font-size: 13px;
  line-height: 1.6;
}

@media (max-width: 1024px) {
  .card-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 768px) {
  .profile-hero__cover {
    height: 210px;
  }

  .profile-hero__body {
    flex-direction: column;
    align-items: stretch;
    padding: 0 20px;
    margin-top: -56px;
  }

  .profile-summary__top,
  .section-heading {
    flex-direction: column;
    align-items: flex-start;
  }

  .profile-actions {
    width: 100%;
    justify-content: flex-start;
  }

  .profile-action-buttons {
    justify-content: flex-start;
  }

  .profile-stats,
  .overview-panels {
    grid-template-columns: 1fr;
  }

  .card-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .profile-shell__tabs,
  .profile-shell__content {
    padding-left: 20px;
    padding-right: 20px;
  }

  .project-card,
  .stack-card {
    flex-direction: column;
    align-items: flex-start;
  }

  .project-card__side,
  .stack-card__actions {
    align-items: flex-start;
  }
}

@media (max-width: 520px) {
  .profile-name {
    font-size: 24px;
  }

  .card-grid {
    grid-template-columns: 1fr;
  }
}
</style>
